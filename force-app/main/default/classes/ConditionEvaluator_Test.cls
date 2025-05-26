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
    static void testEvaluateCondition_NullCondition() {
        Account acc = new Account(Name = 'Test Account');
        
        Test.startTest();
        Boolean result = ConditionEvaluator.evaluateCondition(acc, null, null);
        Test.stopTest();
        
        System.assertEquals(false, result, 'Should return false for null condition');
    }
    
    @isTest
    static void testEvaluateChildObjectCondition_NoChildRecords() {
        // Note: This test would need actual data in a real scenario
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
}
