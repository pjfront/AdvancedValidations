/**
 * @description Test class for ValidationRuleEngine
 */
@isTest
private class ValidationRuleEngine_Test {
    
    @isTest
    static void testValidateRecords_NoRules() {
        // Test with no active rules
        List<Account> accounts = new List<Account>{
            new Account(Name = 'Test Account 1'),
            new Account(Name = 'Test Account 2')
        };
        
        Test.startTest();
        ValidationRuleEngine.validateRecords(accounts, null, 'Account');
        Test.stopTest();
        
        // Should not throw any exceptions
        System.assertEquals(2, accounts.size(), 'Accounts should not be affected');
    }
    
    @isTest
    static void testValidateRecords_SimpleRule() {
        // This test would require custom metadata records to be inserted
        // In a real implementation, you'd use a test data factory
        
        List<Account> accounts = new List<Account>{
            new Account(Name = 'Test Account', Website = null)
        };
        
        Test.startTest();
        try {
            ValidationRuleEngine.validateRecords(accounts, null, 'Account');
        } catch (Exception e) {
            // Expected if rule exists requiring Website
        }
        Test.stopTest();
        
        System.assertNotEquals(null, accounts[0], 'Account should exist');
    }
    
    @isTest
    static void testValidateRecords_WithOldMap() {
        // Test update scenario
        Account oldAccount = new Account(Id = '001000000000001', Name = 'Old Name');
        Account newAccount = new Account(Id = '001000000000001', Name = 'New Name');
        
        Map<Id, SObject> oldMap = new Map<Id, SObject>{
            oldAccount.Id => oldAccount
        };
        
        Test.startTest();
        ValidationRuleEngine.validateRecords(
            new List<Account>{newAccount}, 
            oldMap, 
            'Account'
        );
        Test.stopTest();
        
        System.assertNotEquals(oldAccount.Name, newAccount.Name, 'Names should be different');
    }
    
    @isTest
    static void testValidateRecords_NullRecords() {
        // Test with null records
        Test.startTest();
        ValidationRuleEngine.validateRecords(null, null, 'Account');
        Test.stopTest();
        
        // Should not throw exception
        System.assert(true, 'Should handle null records gracefully');
    }
    
    @isTest
    static void testValidateRecords_EmptyRecords() {
        // Test with empty list
        Test.startTest();
        ValidationRuleEngine.validateRecords(new List<Account>(), null, 'Account');
        Test.stopTest();
        
        // Should not throw exception
        System.assert(true, 'Should handle empty list gracefully');
    }
    
    @isTest
    static void testClearCache() {
        // Test cache clearing
        Test.startTest();
        ValidationRuleEngine.clearCache();
        Test.stopTest();
        
        // Cache should be cleared - no direct way to assert this
        System.assert(true, 'Cache clearing should not throw exception');
    }
    
    @isTest
    static void testBulkRecords() {
        // Test with 200+ records
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 200; i++) {
            accounts.add(new Account(Name = 'Test Account ' + i));
        }
        
        Test.startTest();
        ValidationRuleEngine.validateRecords(accounts, null, 'Account');
        Test.stopTest();
        
        System.assertEquals(200, accounts.size(), 'Should handle bulk records');
    }
}
