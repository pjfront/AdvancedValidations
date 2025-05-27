/**
 * @description Test class for ConditionEvaluator
 */
@isTest
private class ConditionEvaluator_Test {
    
    @isTest
    static void testEvaluateCondition_Equals() {
        Account acc = new Account(Name = 'Test Account', Website = 'www.test.com');
        
        Condition__mdt condition = new Condition__mdt();
        condition.Field__c = 'Name';
        condition.Operator__c = 'equals';
        condition.Value__c = 'Test Account';
        
        Test.startTest();
        Boolean result = ConditionEvaluator.evaluateCondition(acc, null, condition);
        Test.stopTest();
        
        System.assertEquals(true, result, 'Should match when values are equal');
    }
    
    @isTest
    static void testEvaluateCondition_NotEquals() {
        Account acc = new Account(Name = 'Test Account');
        
        Condition__mdt condition = new Condition__mdt();
        condition.Field__c = 'Name';
        condition.Operator__c = 'not equal to';
        condition.Value__c = 'Different Account';
        
        Test.startTest();
        Boolean result = ConditionEvaluator.evaluateCondition(acc, null, condition);
        Test.stopTest();
        
        System.assertEquals(true, result, 'Should be true when values are not equal');
    }
    
    @isTest
    static void testEvaluateCondition_Contains() {
        Account acc = new Account(Name = 'Test Account Company');
        
        Condition__mdt condition = new Condition__mdt();
        condition.Field__c = 'Name';
        condition.Operator__c = 'contains';
        condition.Value__c = 'Account';
        
        Test.startTest();
        Boolean result = ConditionEvaluator.evaluateCondition(acc, null, condition);
        Test.stopTest();
        
        System.assertEquals(true, result, 'Should be true when field contains value');
    }
    
    @isTest
    static void testEvaluateCondition_DoesNotContain() {
        Account acc = new Account(Name = 'Test Company');
        
        Condition__mdt condition = new Condition__mdt();
        condition.Field__c = 'Name';
        condition.Operator__c = 'does not contain';
        condition.Value__c = 'Account';
        
        Test.startTest();
        Boolean result = ConditionEvaluator.evaluateCondition(acc, null, condition);
        Test.stopTest();
        
        System.assertEquals(true, result, 'Should be true when field does not contain value');
    }
    
    @isTest
    static void testEvaluateCondition_IsNull() {
        Account acc = new Account(Name = 'Test Account', Website = null);
        
        Condition__mdt condition = new Condition__mdt();
        condition.Field__c = 'Website';
        condition.Operator__c = 'is null';
        
        Test.startTest();
        Boolean result = ConditionEvaluator.evaluateCondition(acc, null, condition);
        Test.stopTest();
        
        System.assertEquals(true, result, 'Should be true when field is null');
    }
    
    @isTest
    static void testEvaluateCondition_IsNotNull() {
        Account acc = new Account(Name = 'Test Account', Website = 'www.test.com');
        
        Condition__mdt condition = new Condition__mdt();
        condition.Field__c = 'Website';
        condition.Operator__c = 'is not null';
        
        Test.startTest();
        Boolean result = ConditionEvaluator.evaluateCondition(acc, null, condition);
        Test.stopTest();
        
        System.assertEquals(true, result, 'Should be true when field is not null');
    }
    
    @isTest
    static void testEvaluateCondition_Changed() {
        Account oldAcc = new Account(Id = '001000000000001', Name = 'Old Name');
        Account newAcc = new Account(Id = '001000000000001', Name = 'New Name');
        
        Condition__mdt condition = new Condition__mdt();
        condition.Field__c = 'Name';
        condition.Operator__c = 'changed';
        
        Test.startTest();
        Boolean result = ConditionEvaluator.evaluateCondition(newAcc, oldAcc, condition);
        Test.stopTest();
        
        System.assertEquals(true, result, 'Should be true when field has changed');
    }
    
    @isTest
    static void testEvaluateCondition_NotChanged() {
        Account oldAcc = new Account(Id = '001000000000001', Name = 'Same Name');
        Account newAcc = new Account(Id = '001000000000001', Name = 'Same Name');
        
        Condition__mdt condition = new Condition__mdt();
        condition.Field__c = 'Name';
        condition.Operator__c = 'not changed';
        
        Test.startTest();
        Boolean result = ConditionEvaluator.evaluateCondition(newAcc, oldAcc, condition);
        Test.stopTest();
        
        System.assertEquals(true, result, 'Should be true when field has not changed');
    }
    
    @isTest
    static void testEvaluateCondition_GreaterThan() {
        Account acc = new Account(Name = 'Test', AnnualRevenue = 1000000);
        
        Condition__mdt condition = new Condition__mdt();
        condition.Field__c = 'AnnualRevenue';
        condition.Operator__c = 'greater than';
        condition.Value__c = '500000';
        
        Test.startTest();
        Boolean result = ConditionEvaluator.evaluateCondition(acc, null, condition);
        Test.stopTest();
        
        System.assertEquals(true, result, 'Should be true when field is greater than value');
    }
    
    @isTest
    static void testEvaluateCondition_LessThan() {
        Account acc = new Account(Name = 'Test', AnnualRevenue = 100000);
        
        Condition__mdt condition = new Condition__mdt();
        condition.Field__c = 'AnnualRevenue';
        condition.Operator__c = 'less than';
        condition.Value__c = '500000';
        
        Test.startTest();
        Boolean result = ConditionEvaluator.evaluateCondition(acc, null, condition);
        Test.stopTest();
        
        System.assertEquals(true, result, 'Should be true when field is less than value');
    }
    
    @isTest
    static void testEvaluateCondition_GreaterThanOrEqual() {
        Account acc = new Account(Name = 'Test', AnnualRevenue = 500000);
        
        Condition__mdt condition = new Condition__mdt();
        condition.Field__c = 'AnnualRevenue';
        condition.Operator__c = 'greater than or equal';
        condition.Value__c = '500000';
        
        Test.startTest();
        Boolean result = ConditionEvaluator.evaluateCondition(acc, null, condition);
        Test.stopTest();
        
        System.assertEquals(true, result, 'Should be true when field is greater than or equal to value');
    }
    
    @isTest
    static void testEvaluateCondition_LessThanOrEqual() {
        Account acc = new Account(Name = 'Test', AnnualRevenue = 500000);
        
        Condition__mdt condition = new Condition__mdt();
        condition.Field__c = 'AnnualRevenue';
        condition.Operator__c = 'less than or equal';
        condition.Value__c = '500000';
        
        Test.startTest();
        Boolean result = ConditionEvaluator.evaluateCondition(acc, null, condition);
        Test.stopTest();
        
        System.assertEquals(true, result, 'Should be true when field is less than or equal to value');
    }
    
    @isTest
    static void testEvaluateCondition_InvalidOperator() {
        Account acc = new Account(Name = 'Test Account');
        
        Condition__mdt condition = new Condition__mdt();
        condition.Field__c = 'Name';
        condition.Operator__c = 'invalid_operator';
        condition.Value__c = 'Test';
        
        Test.startTest();
        Boolean result = ConditionEvaluator.evaluateCondition(acc, null, condition);
        Test.stopTest();
        
        System.assertEquals(false, result, 'Should return false for invalid operator');
    }
    
    @isTest
    static void testEvaluateCondition_BlankField() {
        Account acc = new Account(Name = 'Test Account');
        
        Condition__mdt condition = new Condition__mdt();
        condition.Field__c = '';
        condition.Operator__c = 'equals';
        condition.Value__c = 'Test';
        
        Test.startTest();
        Boolean result = ConditionEvaluator.evaluateCondition(acc, null, condition);
        Test.stopTest();
        
        System.assertEquals(false, result, 'Should return false for blank field');
    }
    
    @isTest
    static void testEvaluateCondition_ExceptionHandling() {
        Account acc = new Account(Name = 'Test Account');
        
        Condition__mdt condition = new Condition__mdt();
        condition.Field__c = 'InvalidField__c';
        condition.Operator__c = 'equals';
        condition.Value__c = 'Test';
        
        Test.startTest();
        Boolean result = ConditionEvaluator.evaluateCondition(acc, null, condition);
        Test.stopTest();
        
        System.assertEquals(false, result, 'Should return false when exception occurs');
    }
    
    @isTest
    static void testEvaluateCondition_NullCondition() {
        Account acc = new Account(Name = 'Test Account');
        
        Test.startTest();
        Boolean result = ConditionEvaluator.evaluateCondition(acc, null, null);
        Test.stopTest();
        
        System.assertEquals(false, result, 'Should return false for null condition');
    }
    
    @isTest
    static void testEvaluateChildObjectCondition_NoChildRecords() {
        Condition__mdt condition = new Condition__mdt();
        condition.Field__c = 'Contacts';
        condition.Operator__c = 'no fewer than';
        condition.Value__c = '1';
        
        Test.startTest();
        Boolean result = ConditionEvaluator.evaluateChildObjectCondition(
            '001000000000001', 
            condition, 
            new List<Child_Condition__mdt>()
        );
        Test.stopTest();
        
        System.assertEquals(false, result, 'Should return false when no child records exist');
    }
    
    @isTest
    static void testEvaluateChildObjectCondition_NoMoreThan() {
        Condition__mdt condition = new Condition__mdt();
        condition.Field__c = 'Contacts';
        condition.Operator__c = 'no more than';
        condition.Value__c = '5';
        
        Test.startTest();
        Boolean result = ConditionEvaluator.evaluateChildObjectCondition(
            '001000000000001', 
            condition, 
            new List<Child_Condition__mdt>()
        );
        Test.stopTest();
        
        System.assertEquals(true, result, 'Should return true when count is within limit');
    }
    
    @isTest
    static void testEvaluateChildObjectCondition_InvalidOperator() {
        Condition__mdt condition = new Condition__mdt();
        condition.Field__c = 'Contacts';
        condition.Operator__c = 'invalid';
        condition.Value__c = '1';
        
        Test.startTest();
        Boolean result = ConditionEvaluator.evaluateChildObjectCondition(
            '001000000000001', 
            condition, 
            new List<Child_Condition__mdt>()
        );
        Test.stopTest();
        
        System.assertEquals(false, result, 'Should return false for invalid operator');
    }
    
    @isTest
    static void testEvaluateChildObjectCondition_BlankValue() {
        Condition__mdt condition = new Condition__mdt();
        condition.Field__c = 'Contacts';
        condition.Operator__c = 'no fewer than';
        condition.Value__c = '';
        
        Test.startTest();
        Boolean result = ConditionEvaluator.evaluateChildObjectCondition(
            '001000000000001', 
            condition, 
            new List<Child_Condition__mdt>()
        );
        Test.stopTest();
        
        System.assertEquals(false, result, 'Should return false for blank value');
    }
    
    @isTest
    static void testEvaluateChildObjectCondition_NullRecordId() {
        Condition__mdt condition = new Condition__mdt();
        condition.Field__c = 'Contacts';
        condition.Operator__c = 'no fewer than';
        condition.Value__c = '1';
        
        Test.startTest();
        Boolean result = ConditionEvaluator.evaluateChildObjectCondition(
            null, 
            condition, 
            new List<Child_Condition__mdt>()
        );
        Test.stopTest();
        
        System.assertEquals(false, result, 'Should return false for null record ID');
    }
    
    @isTest
    static void testCompareValues_CaseSensitive() {
        Account acc = new Account(Name = 'Test Account');
        
        Condition__mdt condition1 = new Condition__mdt();
        condition1.Field__c = 'Name';
        condition1.Operator__c = 'equals';
        condition1.Value__c = 'test account'; // lowercase
        
        Test.startTest();
        Boolean result1 = ConditionEvaluator.evaluateCondition(acc, null, condition1);
        Test.stopTest();
        
        System.assertEquals(false, result1, 'Should be case sensitive by default');
    }
    
    @isTest
    static void testCompareValues_NullHandling() {
        Account acc = new Account(Name = 'Test Account', Website = null);
        
        Condition__mdt condition = new Condition__mdt();
        condition.Field__c = 'Website';
        condition.Operator__c = 'equals';
        condition.Value__c = '';
        
        Test.startTest();
        Boolean result = ConditionEvaluator.evaluateCondition(acc, null, condition);
        Test.stopTest();
        
        System.assertEquals(true, result, 'Should treat null and empty string as equal');
    }
    
    @isTest
    static void testContainsValue_NullField() {
        Account acc = new Account(Name = 'Test Account', Website = null);
        
        Condition__mdt condition = new Condition__mdt();
        condition.Field__c = 'Website';
        condition.Operator__c = 'contains';
        condition.Value__c = 'test';
        
        Test.startTest();
        Boolean result = ConditionEvaluator.evaluateCondition(acc, null, condition);
        Test.stopTest();
        
        System.assertEquals(false, result, 'Should return false when field is null');
    }
    
    @isTest
    static void testNumericComparison_InvalidNumber() {
        Account acc = new Account(Name = 'Test', Description = 'NotANumber');
        
        Condition__mdt condition = new Condition__mdt();
        condition.Field__c = 'Description';
        condition.Operator__c = 'greater than';
        condition.Value__c = '100';
        
        Test.startTest();
        Boolean result = ConditionEvaluator.evaluateCondition(acc, null, condition);
        Test.stopTest();
        
        System.assertEquals(false, result, 'Should return false for non-numeric comparison');
    }
}
