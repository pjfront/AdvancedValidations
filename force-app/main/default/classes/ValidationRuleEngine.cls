/**
 * @description Main validation rule engine that processes custom metadata-driven validation rules
 * @author Advanced Validations
 */
public with sharing class ValidationRuleEngine {
    
    // Cache for metadata to improve performance
    private static Map<String, List<Parent_Rule__mdt>> ruleCache = new Map<String, List<Parent_Rule__mdt>>();
    private static Map<String, Map<String, List<Condition__mdt>>> conditionCache = new Map<String, Map<String, List<Condition__mdt>>>();
    
    /**
     * @description Main entry point for validation - processes records against active rules
     * @param newRecords List of records being inserted/updated
     * @param oldMap Map of old record values (null for insert)
     * @param objectName API name of the object
     */
    public static void validateRecords(List<SObject> newRecords, Map<Id, SObject> oldMap, String objectName) {
        if (newRecords == null || newRecords.isEmpty()) {
            return;
        }
        
        try {
            // Get active rules for this object
            List<Parent_Rule__mdt> activeRules = getActiveRules(objectName);
            if (activeRules.isEmpty()) {
                return;
            }
            
            // Get all conditions for these rules
            Set<String> ruleNames = new Set<String>();
            for (Parent_Rule__mdt rule : activeRules) {
                ruleNames.add(rule.DeveloperName);
            }
            Map<String, List<Condition__mdt>> conditionsByRule = getConditionsByRule(ruleNames);
            
            // Get child conditions for any child object conditions
            Set<String> conditionNames = new Set<String>();
            for (List<Condition__mdt> conditions : conditionsByRule.values()) {
                for (Condition__mdt condition : conditions) {
                    if (condition.Is_Child_Object__c) {
                        conditionNames.add(condition.DeveloperName);
                    }
                }
            }
            Map<String, List<Child_Condition__mdt>> childConditionsByCondition = 
                getChildConditionsByCondition(conditionNames);
            
            // Evaluate rules against records
            evaluateRules(newRecords, activeRules, oldMap, conditionsByRule, childConditionsByCondition);
            
        } catch (Exception e) {
            // Log error but don't prevent DML operation
            System.debug(LoggingLevel.ERROR, 'ValidationRuleEngine error: ' + e.getMessage() + ' - ' + e.getStackTraceString());
        }
    }
    
    /**
     * @description Retrieves active rules for an object from cache or database
     */
    private static List<Parent_Rule__mdt> getActiveRules(String objectName) {
        String cacheKey = objectName.toLowerCase();
        
        if (!ruleCache.containsKey(cacheKey)) {
            List<Parent_Rule__mdt> rules = [
                SELECT Id, DeveloperName, Object__c, Error_Message__c, 
                       Logic_Type__c, Custom_Logic__c, Active__c, Index__c
                FROM Parent_Rule__mdt
                WHERE Object__c = :objectName
                AND Active__c = true
                ORDER BY Index__c ASC NULLS LAST, DeveloperName ASC
            ];
            ruleCache.put(cacheKey, rules);
        }
        
        return ruleCache.get(cacheKey);
    }
    
    /**
     * @description Retrieves conditions for specified rules
     */
    private static Map<String, List<Condition__mdt>> getConditionsByRule(Set<String> ruleNames) {
        Map<String, List<Condition__mdt>> conditionsByRule = new Map<String, List<Condition__mdt>>();
        
        List<Condition__mdt> allConditions = [
            SELECT Id, DeveloperName, Field__c, Operator__c, Value__c,
                   Logic_Type__c, Custom_Logic__c, Parent_Rule__r.DeveloperName,
                   Is_Child_Object__c
            FROM Condition__mdt
            WHERE Parent_Rule__r.DeveloperName IN :ruleNames
            ORDER BY DeveloperName ASC
        ];
        
        for (Condition__mdt condition : allConditions) {
            String ruleName = condition.Parent_Rule__r.DeveloperName;
            if (!conditionsByRule.containsKey(ruleName)) {
                conditionsByRule.put(ruleName, new List<Condition__mdt>());
            }
            conditionsByRule.get(ruleName).add(condition);
        }
        
        return conditionsByRule;
    }
    
    /**
     * @description Retrieves child conditions for specified parent conditions
     */
    private static Map<String, List<Child_Condition__mdt>> getChildConditionsByCondition(Set<String> conditionNames) {
        Map<String, List<Child_Condition__mdt>> childConditionsByCondition = new Map<String, List<Child_Condition__mdt>>();
        
        if (conditionNames.isEmpty()) {
            return childConditionsByCondition;
        }
        
        List<Child_Condition__mdt> allChildConditions = [
            SELECT Id, DeveloperName, Field__c, Operator__c, Value__c,
                   Parent_Condition__r.DeveloperName, Index__c
            FROM Child_Condition__mdt
            WHERE Parent_Condition__r.DeveloperName IN :conditionNames
            ORDER BY Index__c ASC NULLS LAST, DeveloperName ASC
        ];
        
        for (Child_Condition__mdt childCondition : allChildConditions) {
            String parentName = childCondition.Parent_Condition__r.DeveloperName;
            if (!childConditionsByCondition.containsKey(parentName)) {
                childConditionsByCondition.put(parentName, new List<Child_Condition__mdt>());
            }
            childConditionsByCondition.get(parentName).add(childCondition);
        }
        
        return childConditionsByCondition;
    }
    
    /**
     * @description Evaluates rules against records and adds errors where needed
     */
    private static void evaluateRules(
        List<SObject> records, 
        List<Parent_Rule__mdt> rules,
        Map<Id, SObject> oldMap,
        Map<String, List<Condition__mdt>> conditionsByRule,
        Map<String, List<Child_Condition__mdt>> childConditionsByCondition
    ) {
        for (SObject record : records) {
            SObject oldRecord = (oldMap != null && record.Id != null) ? oldMap.get(record.Id) : null;
            
            for (Parent_Rule__mdt rule : rules) {
                List<Condition__mdt> conditions = conditionsByRule.get(rule.DeveloperName);
                if (conditions == null || conditions.isEmpty()) {
                    continue;
                }
                
                // Evaluate all conditions for this rule
                List<Boolean> conditionResults = new List<Boolean>();
                
                for (Condition__mdt condition : conditions) {
                    Boolean conditionResult;
                    
                    if (condition.Is_Child_Object__c) {
                        // Handle child object condition
                        List<Child_Condition__mdt> childConditions = 
                            childConditionsByCondition.get(condition.DeveloperName);
                        conditionResult = ConditionEvaluator.evaluateChildObjectCondition(
                            record.Id, 
                            condition, 
                            childConditions != null ? childConditions : new List<Child_Condition__mdt>()
                        );
                    } else {
                        // Handle regular field condition
                        conditionResult = ConditionEvaluator.evaluateCondition(record, oldRecord, condition);
                    }
                    
                    conditionResults.add(conditionResult);
                }
                
                // Evaluate the logic for combining conditions
                Boolean ruleTriggered = LogicEvaluator.evaluateLogic(
                    conditionResults, 
                    rule.Logic_Type__c, 
                    rule.Custom_Logic__c
                );
                
                // Add error if rule is triggered
                if (ruleTriggered) {
                    record.addError(rule.Error_Message__c);
                }
            }
        }
    }
    
    /**
     * @description Clears the metadata cache (useful for testing or when metadata changes)
     */
    @TestVisible
    private static void clearCache() {
        ruleCache.clear();
        conditionCache.clear();
    }
}
