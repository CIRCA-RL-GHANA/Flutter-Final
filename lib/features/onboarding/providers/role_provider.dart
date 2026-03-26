import 'package:flutter/foundation.dart';
import '../../../core/services/services.dart';

/// Role category
enum RoleCategory { individual, business }

/// Individual sub-roles
enum IndividualRole { buyer, deliveryPartner, transportProvider, contentCreator }

/// Business sub-roles
enum BusinessRole { owner, administrator, branchManager, staff }

class RoleProvider extends ChangeNotifier {
  // Selected role
  RoleCategory? _selectedCategory;
  RoleCategory? get selectedCategory => _selectedCategory;

  // Sub-roles
  IndividualRole? _individualRole;
  IndividualRole? get individualRole => _individualRole;

  BusinessRole? _businessRole;
  BusinessRole? get businessRole => _businessRole;

  // User reference
  String? _userId;

  // State
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final EntityService _entityService = EntityService();

  void setUserId(String userId) {
    _userId = userId;
  }

  bool get hasSelectedRole => _selectedCategory != null;
  bool get hasSelectedSubRole =>
      (_selectedCategory == RoleCategory.individual && _individualRole != null) ||
      (_selectedCategory == RoleCategory.business && _businessRole != null);

  bool get canProceed => hasSelectedRole && hasSelectedSubRole;

  String get selectedRoleLabel {
    if (_selectedCategory == null) return '';
    return _selectedCategory == RoleCategory.individual ? 'Individual' : 'Business';
  }

  String get selectedSubRoleLabel {
    if (_selectedCategory == RoleCategory.individual) {
      switch (_individualRole) {
        case IndividualRole.buyer:
          return 'Buyer';
        case IndividualRole.deliveryPartner:
          return 'Delivery Partner';
        case IndividualRole.transportProvider:
          return 'Transport Provider';
        case IndividualRole.contentCreator:
          return 'Content Creator';
        default:
          return '';
      }
    } else if (_selectedCategory == RoleCategory.business) {
      switch (_businessRole) {
        case BusinessRole.owner:
          return 'Owner';
        case BusinessRole.administrator:
          return 'Administrator';
        case BusinessRole.branchManager:
          return 'Branch Manager';
        case BusinessRole.staff:
          return 'Staff';
        default:
          return '';
      }
    }
    return '';
  }

  void selectCategory(RoleCategory category) {
    _selectedCategory = category;
    _individualRole = null;
    _businessRole = null;
    notifyListeners();
  }

  void selectIndividualRole(IndividualRole role) {
    _individualRole = role;
    notifyListeners();
  }

  void selectBusinessRole(BusinessRole role) {
    _businessRole = role;
    notifyListeners();
  }

  /// Save role selection to backend by creating entity
  Future<bool> saveRole() async {
    _isLoading = true;
    notifyListeners();

    try {
      final roleType = _selectedCategory == RoleCategory.individual
          ? 'individual'
          : 'business';
      final subRole = _selectedCategory == RoleCategory.individual
          ? _individualRole?.name ?? ''
          : _businessRole?.name ?? '';

      final response = await _entityService.createIndividual(
        ownerId: _userId ?? '',
        entityType: roleType,
        role: subRole,
        displayName: subRole,
      );

      _isLoading = false;
      notifyListeners();
      return response.success;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Get role-specific features description
  List<String> getCategoryFeatures(RoleCategory category) {
    if (category == RoleCategory.individual) {
      return ['Personal Use', 'Shopping', 'Social', 'Finance'];
    } else {
      return ['Run a Shop', 'Manage Staff', 'Handle Orders', 'Analytics'];
    }
  }

  void reset() {
    _selectedCategory = null;
    _individualRole = null;
    _businessRole = null;
    _isLoading = false;
    notifyListeners();
  }
}
