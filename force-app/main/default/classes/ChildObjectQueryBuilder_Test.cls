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
}
