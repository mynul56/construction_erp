"""
management/commands/seed_data.py
Run: python manage.py seed_data
Creates realistic test data matching the Flutter app's mock data shapes.
"""
import random
from datetime import date, timedelta, time
from django.core.management.base import BaseCommand
from django.utils import timezone

from apps.authentication.models import User, UserRole
from apps.projects.models import Project, ProjectStatus
from apps.workforce.models import Worker, Attendance, AttendanceStatus
from apps.inventory.models import InventoryItem, InventoryCategory
from apps.payroll.models import PayrollRecord, PayrollStatus


class Command(BaseCommand):
    help = 'Seeds realistic development data for the Construction ERP'

    def handle(self, *args, **options):
        self.stdout.write('🌱 Seeding data...')
        self._create_users()
        self._create_projects()
        self._create_workers()
        self._create_attendance()
        self._create_inventory()
        self._create_payroll()
        self.stdout.write(self.style.SUCCESS('✅ Seeding complete!'))

    def _create_users(self):
        # Admin
        if not User.objects.filter(email='admin@constructio.app').exists():
            User.objects.create_superuser(
                email='admin@constructio.app',
                password='admin123',
                name='Admin User',
                role=UserRole.ADMIN,
            )
            self.stdout.write('  Admin: admin@constructio.app / admin123')

        # Site managers
        managers = [
            ('manager@constructio.app', 'Rashid Khan', 'manager123'),
            ('priya@constructio.app', 'Priya Das', 'manager123'),
        ]
        for email, name, pwd in managers:
            if not User.objects.filter(email=email).exists():
                User.objects.create_user(
                    email=email, password=pwd, name=name,
                    role=UserRole.SITE_MANAGER
                )

        # Workers
        worker_data = [
            ('hasan@constructio.app', 'Md. Hasan Ali', 'worker123'),
            ('rahim@constructio.app', 'Rahim Uddin', 'worker123'),
            ('karim@constructio.app', 'Karim Sheikh', 'worker123'),
            ('fatema@constructio.app', 'Fatema Begum', 'worker123'),
            ('jamal@constructio.app', 'Jamal Hossain', 'worker123'),
            ('nasrin@constructio.app', 'Nasrin Khatun', 'worker123'),
        ]
        for email, name, pwd in worker_data:
            if not User.objects.filter(email=email).exists():
                User.objects.create_user(
                    email=email, password=pwd, name=name,
                    role=UserRole.WORKER
                )
        self.stdout.write('  Users created')

    def _create_projects(self):
        manager = User.objects.filter(role=UserRole.SITE_MANAGER).first()
        projects = [
            ('Tower Block A', 'Dhaka', ProjectStatus.IN_PROGRESS, 72, 1200000, 864000),
            ('Highway Overpass', 'Chittagong', ProjectStatus.IN_PROGRESS, 45, 3500000, 1575000),
            ('Commercial Complex', 'Sylhet', ProjectStatus.PLANNING, 18, 2800000, 504000),
            ('Bridge Renovation', 'Khulna', ProjectStatus.COMPLETED, 100, 900000, 900000),
        ]
        for name, loc, st, prog, budget, spent in projects:
            Project.objects.get_or_create(
                name=name,
                defaults={
                    'location': loc,
                    'status': st,
                    'progress': prog,
                    'budget': budget,
                    'spent': spent,
                    'site_manager': manager,
                    'start_date': date.today() - timedelta(days=random.randint(30, 120)),
                    'due_date': date.today() + timedelta(days=random.randint(30, 180)),
                }
            )
        self.stdout.write('  Projects created')

    def _create_workers(self):
        worker_meta = [
            ('hasan@constructio.app', 'EMP001', 'Mason', 800),
            ('rahim@constructio.app', 'EMP002', 'Electrician', 900),
            ('karim@constructio.app', 'EMP003', 'Welder', 850),
            ('fatema@constructio.app', 'EMP004', 'Plumber', 780),
            ('jamal@constructio.app', 'EMP005', 'Carpenter', 820),
            ('nasrin@constructio.app', 'EMP006', 'Supervisor', 1100),
        ]
        for email, emp_id, desig, rate in worker_meta:
            try:
                user = User.objects.get(email=email)
                Worker.objects.get_or_create(
                    user=user,
                    defaults={
                        'employee_id': emp_id,
                        'designation': desig,
                        'daily_rate': rate,
                        'joining_date': date.today() - timedelta(days=random.randint(90, 365)),
                    }
                )
            except User.DoesNotExist:
                pass
        self.stdout.write('  Workers created')

    def _create_attendance(self):
        workers = Worker.objects.select_related('user').all()
        project = Project.objects.first()
        today = date.today()
        statuses = [
            AttendanceStatus.PRESENT,
            AttendanceStatus.PRESENT,
            AttendanceStatus.PRESENT,
            AttendanceStatus.LATE,
            AttendanceStatus.ABSENT,
        ]
        for worker in workers:
            for i in range(7):
                d = today - timedelta(days=i)
                att_status = random.choice(statuses)
                check_in = None
                if att_status in (AttendanceStatus.PRESENT,):
                    check_in = time(8, random.randint(0, 30))
                elif att_status == AttendanceStatus.LATE:
                    check_in = time(9, random.randint(15, 59))
                Attendance.objects.get_or_create(
                    worker=worker,
                    date=d,
                    defaults={
                        'project': project,
                        'status': att_status,
                        'check_in': check_in,
                    }
                )
        self.stdout.write('  Attendance (7 days) created')

    def _create_inventory(self):
        items = [
            ('TMT Steel Bars', InventoryCategory.STEEL, 450, 'ton', 85000, 100, 'Warehouse A'),
            ('Portland Cement', InventoryCategory.CEMENT, 30, 'bags', 450, 50, 'Site B'),
            ('Teak Timber', InventoryCategory.TIMBER, 280, 'pcs', 1200, 50, 'Warehouse B'),
            ('Safety Helmets', InventoryCategory.SAFETY, 15, 'units', 800, 30, 'Site A'),
            ('Copper Wire', InventoryCategory.ELECTRICAL, 120, 'm', 120, 40, 'Warehouse A'),
            ('PVC Pipes', InventoryCategory.PLUMBING, 200, 'pcs', 350, 60, 'Site B'),
        ]
        for name, cat, qty, unit, price, threshold, loc in items:
            InventoryItem.objects.get_or_create(
                name=name,
                defaults={
                    'category': cat,
                    'quantity': qty,
                    'unit': unit,
                    'unit_price': price,
                    'low_stock_threshold': threshold,
                    'location': loc,
                }
            )
        self.stdout.write('  Inventory created')

    def _create_payroll(self):
        workers = Worker.objects.all()
        today = date.today()
        for worker in workers:
            base = float(worker.daily_rate) * 26  # 26 working days
            for m_offset in range(3):
                m = today.month - m_offset
                y = today.year
                if m <= 0:
                    m += 12
                    y -= 1
                PayrollRecord.objects.get_or_create(
                    worker=worker,
                    month=m,
                    year=y,
                    defaults={
                        'base_salary': base,
                        'bonus': random.choice([0, 2000, 5000]),
                        'deductions': random.choice([0, 500, 1000]),
                        'status': PayrollStatus.PAID if m_offset > 0 else PayrollStatus.PENDING,
                    }
                )
        self.stdout.write('  Payroll records created')
