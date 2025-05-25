/**
 * @description Custom exception for validation rule errors
 */
public class ValidationRuleException extends Exception {
    // Custom exception class for validation rule specific errors
    // The Exception class already provides getMessage() and setMessage() methods
    
    /**
     * @description Override to create custom message format
     */
    public static ValidationRuleException createException(String ruleName, String errorMessage) {
        ValidationRuleException ex = new ValidationRuleException();
        ex.setMessage('Rule: ' + ruleName + ' - ' + errorMessage);
        return ex;
    }
    
    /**
     * @description Create exception with just a message
     */
    public static ValidationRuleException createException(String message) {
        ValidationRuleException ex = new ValidationRuleException();
        ex.setMessage(message);
        return ex;
    }
}
