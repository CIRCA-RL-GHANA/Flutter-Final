/// Standardized error codes matching backend constants.
/// Used for consistent error handling across the app.
class ErrorCodes {
  ErrorCodes._();

  // ─── Auth ──────────────────────────────────────────
  static const unauthorized = 'UNAUTHORIZED';
  static const invalidCredentials = 'INVALID_CREDENTIALS';
  static const tokenExpired = 'TOKEN_EXPIRED';
  static const tokenInvalid = 'TOKEN_INVALID';
  static const phoneNotVerified = 'PHONE_NOT_VERIFIED';
  static const biometricNotVerified = 'BIOMETRIC_NOT_VERIFIED';

  // ─── Validation ───────────────────────────────────
  static const validationError = 'VALIDATION_ERROR';
  static const invalidInput = 'INVALID_INPUT';
  static const missingRequiredField = 'MISSING_REQUIRED_FIELD';

  // ─── Resource ─────────────────────────────────────
  static const resourceNotFound = 'RESOURCE_NOT_FOUND';
  static const duplicateResource = 'DUPLICATE_RESOURCE';
  static const resourceConflict = 'RESOURCE_CONFLICT';

  // ─── QPoints ──────────────────────────────────────
  static const insufficientBalance = 'INSUFFICIENT_BALANCE';
  static const transactionFailed = 'TRANSACTION_FAILED';
  static const fraudDetected = 'FRAUD_DETECTED';
  static const dailyLimitExceeded = 'DAILY_LIMIT_EXCEEDED';

  // ─── User/Registration ────────────────────────────
  static const phoneExists = 'PHONE_EXISTS';
  static const usernameTaken = 'USERNAME_TAKEN';
  static const wireIdExists = 'WIRE_ID_EXISTS';
  static const otpExpired = 'OTP_EXPIRED';
  static const otpInvalid = 'OTP_INVALID';
  static const otpMaxAttempts = 'OTP_MAX_ATTEMPTS';

  // ─── Permissions ──────────────────────────────────
  static const forbidden = 'FORBIDDEN';
  static const insufficientPermissions = 'INSUFFICIENT_PERMISSIONS';
  static const featureNotAvailable = 'FEATURE_NOT_AVAILABLE';

  // ─── Rate Limiting ────────────────────────────────
  static const rateLimitExceeded = 'RATE_LIMIT_EXCEEDED';

  // ─── Server ───────────────────────────────────────
  static const internalServerError = 'INTERNAL_SERVER_ERROR';
  static const serviceUnavailable = 'SERVICE_UNAVAILABLE';

  // ─── Network (Frontend only) ──────────────────────
  static const networkError = 'NETWORK_ERROR';
  static const timeout = 'TIMEOUT';
  static const connectionRefused = 'CONNECTION_REFUSED';
}
