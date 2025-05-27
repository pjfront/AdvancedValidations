/**
 * @description Test class for ChildObjectQueryBuilder
 */
@isTest
private class ChildObjectQueryBuilder_Test {
    
    @isTest
    static void testBuildChildObjectQuery_Basic() {
        Set<Id> parentIds = new Set<Id>{'001000000000001'};
        List<Child_Condition__mdt> conditions = new List<Child_Condition__mdt>();
        
        Child_Condition__mdt condition = new Child_Condition__mdt();
        condition.Field__c = 'FirstName';
        condition.Operator__c = 'equals';
        condition.Value__c = 'John';
        conditions.add(condition);
        
        Test.startTest();
        String query = ChildObjectQueryBuilder.buildChildObjectQuery(
            'Contacts', 
            parentIds, 
            conditions,
            'AND',
            null
        );
        Test.stopTest();
        
        System.assertNotEquals(null, query, 'Query should not be null');
        System.assert(query.contains('FROM Contact'), 'Query should include FROM Contact');
        System.assert(query.contains('WHERE AccountId IN :parentIds'), 'Query should filter by parent IDs');
    }
    
    @isTest
    static void testBuildChildObjectQuery_NoConditions() {
        Set<Id> parentIds = new Set<Id>{'001000000000001'};
        
        Test.startTest();
        String query = ChildObjectQueryBuilder.buildChildObjectQuery(
            'Contacts', 
            parentIds, 
            new List<Child_Condition__mdt>(),
            'AND',
            null
        );
        Test.stopTest();
        
        System.assertNotEquals(null, query, 'Query should not be null');
        System.assert(!query.contains('AND ('), 'Query should not have condition clause');
    }
    
    @isTest
    static void testBuildChildObjectQuery_WithOR() {
        Set<Id> parentIds = new Set<Id>{'001000000000001'};
        List<Child_Condition__mdt> conditions = new List<Child_Condition__mdt>();
        
        Child_Condition__mdt condition1 = new Child_Condition__mdt();
        condition1.Field__c = 'FirstName';
        condition1.Operator__c = 'equals';
        condition1.Value__c = 'John';
        conditions.add(condition1);
        
        Child_Condition__mdt condition2 = new Child_Condition__mdt();
        condition2.Field__c = 'LastName';
        condition2.Operator__c = 'equals';
        condition2.Value__c = 'Doe';
        conditions.add(condition2);
        
        Test.startTest();
        String query = ChildObjectQueryBuilder.buildChildObjectQuery(
            'Contacts', 
            parentIds, 
            conditions,
            'OR',
            null
        );
        Test.stopTest();
        
        System.assertNotEquals(null, query, 'Query should not be null');
        System.assert(query.contains(' OR '), 'Query should use OR logic');
    }
    
    @isTest
    static void testBuildChildObjectQuery_WithCustomLogic() {
        Set<Id> parentIds = new Set<Id>{'001000000000001'};
        List<Child_Condition__mdt> conditions = new List<Child_Condition__mdt>();
        
        Child_Condition__mdt condition1 = new Child_Condition__mdt();
        condition1.Field__c = 'FirstName';
        condition1.Operator__c = 'equals';
        condition1.Value__c = 'John';
        conditions.add(condition1);
        
        Child_Condition__mdt condition2 = new Child_Condition__mdt();
        condition2.Field__c = 'LastName';
        condition2.Operator__c = 'equals';
        condition2.Value__c = 'Doe';
        conditions.add(condition2);
        
        Test.startTest();
        String query = ChildObjectQueryBuilder.buildChildObjectQuery(
            'Contacts', 
            parentIds, 
            conditions,
            'CUSTOM',
            '1 OR 2'
        );
        Test.stopTest();
        
        System.assertNotEquals(null, query, 'Query should not be null');
    }
    
    @isTest
    static void testBuildChildObjectQuery_AllOperators() {
        Set<Id> parentIds = new Set<Id>{'001000000000001'};
        List<Child_Condition__mdt> conditions = new List<Child_Condition__mdt>();
        
        // Test various operators
        Child_Condition__mdt cond1 = new Child_Condition__mdt();
        cond1.Field__c = 'FirstName';
        cond1.Operator__c = 'is null';
        conditions.add(cond1);
        
        Child_Condition__mdt cond2 = new Child_Condition__mdt();
        cond2.Field__c = 'LastName';
        cond2.Operator__c = 'is not null';
        conditions.add(cond2);
        
        Child_Condition__mdt cond3 = new Child_Condition__mdt();
        cond3.Field__c = 'Email';
        cond3.Operator__c = 'not equal to';
        cond3.Value__c = 'test@example.com';
        conditions.add(cond3);
        
        Child_Condition__mdt cond4 = new Child_Condition__mdt();
        cond4.Field__c = 'Title';
        cond4.Operator__c = 'contains';
        cond4.Value__c = 'Manager';
        conditions.add(cond4);
        
        Child_Condition__mdt cond5 = new Child_Condition__mdt();
        cond5.Field__c = 'Department';
        cond5.Operator__c = 'does not contain';
        cond5.Value__c = 'Sales';
        conditions.add(cond5);
        
        Child_Condition__mdt cond6 = new Child_Condition__mdt();
        cond6.Field__c = 'NumberOfEmployees';
        cond6.Operator__c = 'greater than';
        cond6.Value__c = '100';
        conditions.add(cond6);
        
        Child_Condition__mdt cond7 = new Child_Condition__mdt();
        cond7.Field__c = 'AnnualRevenue';
        cond7.Operator__c = 'less than';
        cond7.Value__c = '1000000';
        conditions.add(cond7);
        
        Test.startTest();
        String query = ChildObjectQueryBuilder.buildChildObjectQuery(
            'Contacts', 
            parentIds, 
            conditions,
            'AND',
            null
        );
        Test.stopTest();
        
        System.assertNotEquals(null, query, 'Query should not be null');
        System.assert(query.contains('= null'), 'Query should include is null');
        System.assert(query.contains('!= null'), 'Query should include is not null');
        System.assert(query.contains('LIKE'), 'Query should include LIKE');
        System.assert(query.contains('NOT'), 'Query should include NOT');
    }
    
    @isTest
    static void testBuildChildObjectQuery_NullInputs() {
        Test.startTest();
        String query = ChildObjectQueryBuilder.buildChildObjectQuery(
            null, 
            null, 
            null,
            null,
            null
        );
        Test.stopTest();
        
        System.assertEquals(null, query, 'Query should be null for null inputs');
    }
    
    @isTest
    static void testBuildChildObjectQuery_EmptyRelationship() {
        Set<Id> parentIds = new Set<Id>{'001000000000001'};
        
        Test.startTest();
        String query = ChildObjectQueryBuilder.buildChildObjectQuery(
            '', 
            parentIds, 
            new List<Child_Condition__mdt>(),
            'AND',
            null
        );
        Test.stopTest();
        
        System.assertEquals(null, query, 'Query should be null for empty relationship');
    }
    
    @isTest
    static void testBuildChildObjectQuery_CustomObject() {
        Set<Id> parentIds = new Set<Id>{'001000000000001'};
        
        Test.startTest();
        String query = ChildObjectQueryBuilder.buildChildObjectQuery(
            'Custom_Objects__r', 
            parentIds, 
            new List<Child_Condition__mdt>(),
            'AND',
            null
        );
        Test.stopTest();
        
        System.assertNotEquals(null, query, 'Query should handle custom objects');
        System.assert(query.contains('FROM Custom_Objects__c'), 'Query should convert __r to __c');
    }
    
    @isTest
    static void testBuildChildObjectQuery_InvalidOperator() {
        Set<Id> parentIds = new Set<Id>{'001000000000001'};
        List<Child_Condition__mdt> conditions = new List<Child_Condition__mdt>();
        
        Child_Condition__mdt condition = new Child_Condition__mdt();
        condition.Field__c = 'FirstName';
        condition.Operator__c = 'invalid_operator';
        condition.Value__c = 'John';
        conditions.add(condition);
        
        Test.startTest();
        String query = ChildObjectQueryBuilder.buildChildObjectQuery(
            'Contacts', 
            parentIds, 
            conditions,
            'AND',
            null
        );
        Test.stopTest();
        
        System.assertNotEquals(null, query, 'Query should not be null');
        System.assert(!query.contains('invalid_operator'), 'Query should skip invalid operators');
    }
    
    @isTest
    static void testGetChildRecordCounts_EmptyParentIds() {
        Set<Id> parentIds = new Set<Id>();
        Condition__mdt condition = new Condition__mdt();
        condition.Field__c = 'Contacts';
        
        Test.startTest();
        Map<Id, Integer> counts = ChildObjectQueryBuilder.getChildRecordCounts(
            parentIds, 
            condition, 
            new List<Child_Condition__mdt>()
        );
        Test.stopTest();
        
        System.assertEquals(0, counts.size(), 'Should return empty map for empty parent IDs');
    }
    
    @isTest
    static void testGetChildRecordCounts_NullCondition() {
        Set<Id> parentIds = new Set<Id>{'001000000000001'};
        
        Test.startTest();
        Map<Id, Integer> counts = ChildObjectQueryBuilder.getChildRecordCounts(
            parentIds, 
            null, 
            new List<Child_Condition__mdt>()
        );
        Test.stopTest();
        
        System.assertEquals(0, counts.size(), 'Should return empty map for null condition');
    }
    
    @isTest
    static void testGetChildRecordCounts_WithConditions() {
        Set<Id> parentIds = new Set<Id>{'001000000000001', '001000000000002'};
        Condition__mdt condition = new Condition__mdt();
        condition.Field__c = 'Contacts';
        condition.Logic_Type__c = 'AND';
        
        List<Child_Condition__mdt> childConditions = new List<Child_Condition__mdt>();
        Child_Condition__mdt childCond = new Child_Condition__mdt();
        childCond.Field__c = 'FirstName';
        childCond.Operator__c = 'equals';
        childCond.Value__c = 'John';
        childConditions.add(childCond);
        
        Test.startTest();
        Map<Id, Integer> counts = ChildObjectQueryBuilder.getChildRecordCounts(
            parentIds, 
            condition, 
            childConditions
        );
        Test.stopTest();
        
        System.assertNotEquals(null, counts, 'Should return a map');
        System.assertEquals(2, counts.size(), 'Should initialize counts for all parent IDs');
        System.assertEquals(0, counts.get('001000000000001'), 'Should initialize to 0');
    }
    
    @isTest
    static void testFormatValue_Boolean() {
        Set<Id> parentIds = new Set<Id>{'001000000000001'};
        List<Child_Condition__mdt> conditions = new List<Child_Condition__mdt>();
        
        Child_Condition__mdt condition = new Child_Condition__mdt();
        condition.Field__c = 'IsActive';
        condition.Operator__c = 'equals';
        condition.Value__c = 'true';
        conditions.add(condition);
        
        Test.startTest();
        String query = ChildObjectQueryBuilder.buildChildObjectQuery(
            'Contacts', 
            parentIds, 
            conditions,
            'AND',
            null
        );
        Test.stopTest();
        
        System.assertNotEquals(null, query, 'Query should not be null');
        System.assert(query.contains('= true'), 'Query should format boolean correctly');
    }
    
    @isTest
    static void testFormatValue_Number() {
        Set<Id> parentIds = new Set<Id>{'001000000000001'};
        List<Child_Condition__mdt> conditions = new List<Child_Condition__mdt>();
        
        Child_Condition__mdt condition = new Child_Condition__mdt();
        condition.Field__c = 'NumberOfEmployees';
        condition.Operator__c = 'equals';
        condition.Value__c = '100';
        conditions.add(condition);
        
        Test.startTest();
        String query = ChildObjectQueryBuilder.buildChildObjectQuery(
            'Contacts', 
            parentIds, 
            conditions,
            'AND',
            null
        );
        Test.stopTest();
        
        System.assertNotEquals(null, query, 'Query should not be null');
        System.assert(query.contains('= 100'), 'Query should format number correctly');
    }
    
    @isTest
    static void testFormatValue_String() {
        Set<Id> parentIds = new Set<Id>{'001000000000001'};
        List<Child_Condition__mdt> conditions = new List<Child_Condition__mdt>();
        
        Child_Condition__mdt condition = new Child_Condition__mdt();
        condition.Field__c = 'Name';
        condition.Operator__c = 'equals';
        condition.Value__c = 'Test\'s Name'; // With apostrophe
        conditions.add(condition);
        
        Test.startTest();
        String query = ChildObjectQueryBuilder.buildChildObjectQuery(
            'Contacts', 
            parentIds, 
            conditions,
            'AND',
            null
        );
        Test.stopTest();
        
        System.assertNotEquals(null, query, 'Query should not be null');
        System.assert(query.contains('\'Test\\\'s Name\''), 'Query should escape single quotes');
    }
    
    @isTest
    static void testGetChildObjectName_StandardPlural() {
        Set<Id> parentIds = new Set<Id>{'001000000000001'};
        
        Test.startTest();
        String query = ChildObjectQueryBuilder.buildChildObjectQuery(
            'Opportunities', 
            parentIds, 
            new List<Child_Condition__mdt>(),
            'AND',
            null
        );
        Test.stopTest();
        
        System.assertNotEquals(null, query, 'Query should not be null');
        System.assert(query.contains('FROM Opportunitie'), 'Should handle standard plural');
    }
}
