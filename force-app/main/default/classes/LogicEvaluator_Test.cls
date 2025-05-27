/**
 * @description Test class for LogicEvaluator
 */
@isTest
private class LogicEvaluator_Test {
    
    @isTest
    static void testEvaluateLogic_AND_AllTrue() {
        List<Boolean> results = new List<Boolean>{true, true, true};
        
        Test.startTest();
        Boolean result = LogicEvaluator.evaluateLogic(results, 'AND', null);
        Test.stopTest();
        
        System.assertEquals(true, result, 'AND logic should return true when all conditions are true');
    }
    
    @isTest
    static void testEvaluateLogic_AND_OneFalse() {
        List<Boolean> results = new List<Boolean>{true, false, true};
        
        Test.startTest();
        Boolean result = LogicEvaluator.evaluateLogic(results, 'AND', null);
        Test.stopTest();
        
        System.assertEquals(false, result, 'AND logic should return false when any condition is false');
    }
    
    @isTest
    static void testEvaluateLogic_OR_AllFalse() {
        List<Boolean> results = new List<Boolean>{false, false, false};
        
        Test.startTest();
        Boolean result = LogicEvaluator.evaluateLogic(results, 'OR', null);
        Test.stopTest();
        
        System.assertEquals(false, result, 'OR logic should return false when all conditions are false');
    }
    
    @isTest
    static void testEvaluateLogic_OR_OneTrue() {
        List<Boolean> results = new List<Boolean>{false, true, false};
        
        Test.startTest();
        Boolean result = LogicEvaluator.evaluateLogic(results, 'OR', null);
        Test.stopTest();
        
        System.assertEquals(true, result, 'OR logic should return true when any condition is true');
    }
    
    @isTest
    static void testEvaluateLogic_SingleCondition() {
        List<Boolean> results = new List<Boolean>{true};
        
        Test.startTest();
        Boolean result = LogicEvaluator.evaluateLogic(results, 'AND', null);
        Test.stopTest();
        
        System.assertEquals(true, result, 'Should return the single condition result');
    }
    
    @isTest
    static void testEvaluateLogic_EmptyList() {
        List<Boolean> results = new List<Boolean>();
        
        Test.startTest();
        Boolean result = LogicEvaluator.evaluateLogic(results, 'AND', null);
        Test.stopTest();
        
        System.assertEquals(false, result, 'Should return false for empty list');
    }
    
    @isTest
    static void testEvaluateLogic_NullList() {
        Test.startTest();
        Boolean result = LogicEvaluator.evaluateLogic(null, 'AND', null);
        Test.stopTest();
        
        System.assertEquals(false, result, 'Should return false for null list');
    }
    
    @isTest
    static void testEvaluateLogic_CustomLogic_Simple() {
        List<Boolean> results = new List<Boolean>{true, false, true};
        String customLogic = '1 AND (2 OR 3)';
        
        Test.startTest();
        Boolean result = LogicEvaluator.evaluateLogic(results, 'CUSTOM', customLogic);
        Test.stopTest();
        
        System.assertEquals(true, result, 'Custom logic: 1 AND (2 OR 3) = true AND (false OR true) = true');
    }
    
    @isTest
    static void testEvaluateLogic_CustomLogic_Complex() {
        List<Boolean> results = new List<Boolean>{true, false, true, false};
        String customLogic = '(1 AND 2) OR (3 AND 4)';
        
        Test.startTest();
        Boolean result = LogicEvaluator.evaluateLogic(results, 'CUSTOM', customLogic);
        Test.stopTest();
        
        System.assertEquals(false, result, 'Custom logic: (true AND false) OR (true AND false) = false');
    }
    
    @isTest
    static void testEvaluateLogic_CustomLogic_Invalid() {
        List<Boolean> results = new List<Boolean>{true, false};
        String customLogic = '1 AND 2 AND 3'; // References non-existent condition 3
        
        Test.startTest();
        Boolean result = LogicEvaluator.evaluateLogic(results, 'CUSTOM', customLogic);
        Test.stopTest();
        
        System.assertEquals(false, result, 'Should return false for invalid custom logic');
    }
    
    @isTest
    static void testEvaluateLogic_CustomLogic_UnbalancedParentheses() {
        List<Boolean> results = new List<Boolean>{true, false};
        String customLogic = '(1 AND 2'; // Unbalanced parentheses
        
        Test.startTest();
        Boolean result = LogicEvaluator.evaluateLogic(results, 'CUSTOM', customLogic);
        Test.stopTest();
        
        System.assertEquals(false, result, 'Should return false for unbalanced parentheses');
    }
    
    @isTest
    static void testEvaluateLogic_DefaultsToAND() {
        List<Boolean> results = new List<Boolean>{true, true};
        
        Test.startTest();
        Boolean result = LogicEvaluator.evaluateLogic(results, 'INVALID_TYPE', null);
        Test.stopTest();
        
        System.assertEquals(true, result, 'Should default to AND logic for invalid type');
    }
}
