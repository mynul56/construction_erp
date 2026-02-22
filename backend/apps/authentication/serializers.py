"""
Authentication serializers — login, token response, user profile.
"""
from django.contrib.auth import authenticate
from rest_framework import serializers
from .models import User


class LoginSerializer(serializers.Serializer):
    email = serializers.EmailField()
    password = serializers.CharField(write_only=True)
    role = serializers.ChoiceField(
        choices=['worker', 'site_manager', 'admin'],
        required=False,
        help_text='Optional: validates that the user has this role'
    )

    def validate(self, attrs):
        email = attrs.get('email')
        password = attrs.get('password')
        requested_role = attrs.get('role')

        user = authenticate(username=email, password=password)
        if not user:
            raise serializers.ValidationError('Invalid email or password.')
        if not user.is_active:
            raise serializers.ValidationError('User account is disabled.')
        if requested_role and user.role != requested_role:
            raise serializers.ValidationError(
                f'This account does not have the {requested_role} role.'
            )
        attrs['user'] = user
        return attrs


class UserSerializer(serializers.ModelSerializer):
    role_label = serializers.ReadOnlyField()
    profile_data = serializers.SerializerMethodField()

    class Meta:
        model = User
        fields = [
            'id', 'email', 'name', 'role', 'role_label',
            'phone', 'avatar_url', 'created_at', 'profile_data',
        ]
        read_only_fields = ['id', 'created_at']

    def get_profile_data(self, obj):
        if obj.role == 'worker' and hasattr(obj, 'worker_profile'):
            return {
                'employee_id': obj.worker_profile.employee_id,
                'designation': obj.worker_profile.designation,
                'daily_rate': str(obj.worker_profile.daily_rate),
                'joining_date': obj.worker_profile.joining_date,
            }
        elif obj.role == 'site_manager' and hasattr(obj, 'site_manager_profile'):
            return {
                'employee_id': obj.site_manager_profile.employee_id,
                'department': obj.site_manager_profile.department,
                'years_of_experience': obj.site_manager_profile.years_of_experience,
            }
        elif obj.role == 'admin' and hasattr(obj, 'admin_profile'):
            return {
                'employee_id': obj.admin_profile.employee_id,
                'department': obj.admin_profile.department,
                'admin_level': obj.admin_profile.admin_level,
            }
        return None


class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, min_length=6)
    confirm_password = serializers.CharField(write_only=True)

    class Meta:
        model = User
        fields = ['email', 'name', 'role', 'phone', 'password', 'confirm_password']

    def validate(self, attrs):
        if attrs['password'] != attrs.pop('confirm_password'):
            raise serializers.ValidationError("Passwords do not match.")
        return attrs

    def create(self, validated_data):
        return User.objects.create_user(**validated_data)


class ChangePasswordSerializer(serializers.Serializer):
    old_password = serializers.CharField(write_only=True)
    new_password = serializers.CharField(write_only=True, min_length=6)

    def validate_old_password(self, value):
        user = self.context['request'].user
        if not user.check_password(value):
            raise serializers.ValidationError('Old password is incorrect.')
        return value
