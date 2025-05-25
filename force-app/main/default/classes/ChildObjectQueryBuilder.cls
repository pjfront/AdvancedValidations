/**
 * @description Builds and executes dynamic SOQL queries for child object validation
 */
public with sharing class ChildObjectQueryBuilder {
    
    /**
     * @description Gets count of child records matching conditions
     */
    public static Map<Id, Integer> getChildRecordCounts(
        Set<Id> parentIds, 
        Condition__mdt condition, 
        List<Child_Condition__mdt> childConditions
    ) {
        Map<Id, Integer> countsByParentId = new Map<Id, Integer>();
        
        if (parentIds == null || parentIds.isEmpty() || condition == null) {
            return countsByParentId;
        }
        
        try {
            // Initialize counts to 0
            for (Id parentId : parentIds) {
                countsByParentId.put(parentId, 0);
            }
            
            // Build and execute query
            String query = buildChildObjectQuery(
                condition.Field__c, 
                parentIds, 
                childConditions,
                condition.Logic_Type__c,
                condition.Custom_Logic__c
            );
            
            if (String.isNotBlank(query)) {
                List<SObject> results = Database.query(query);
                
                // Count matching records per parent
                for (SObject record : results) {
                    Id parentId = (Id) record.get(getParentFieldName(condition.Field__c));
                    Integer currentCount = countsByParentId.get(parentId);
                    countsByParentId.put(parentId, currentCount + 1);
                }
            }
            
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error querying child records: ' + e.getMessage());
        }
        
        return countsByParentId;
    }
    
    /**
     * @description Builds dynamic SOQL query for child objects
     */
    @TestVisible
    private static String buildChildObjectQuery(
        String childRelationship, 
        Set<Id> parentIds, 
        List<Child_Condition__mdt> conditions,
        String logicType,
        String customLogic
    ) {
        if (String.isBlank(childRelationship) || parentIds == null || parentIds.isEmpty()) {
            return null;
        }
        
        try {
            // Get child object name and parent field
            String childObjectName = getChildObjectName(childRelationship);
            String parentFieldName = getParentFieldName(childRelationship);
            
            if (String.isBlank(childObjectName) || String.isBlank(parentFieldName)) {
                return null;
            }
            
            // Build SELECT clause
            String query = 'SELECT Id, ' + parentFieldName;
            
            // Add fields needed for conditions
            Set<String> fieldsToQuery = new Set<String>{'Id', parentFieldName};
            if (conditions != null) {
                for (Child_Condition__mdt condition : conditions) {
                    if (String.isNotBlank(condition.Field__c) && 
                        !fieldsToQuery.contains(condition.Field__c.toLowerCase())) {
                        fieldsToQuery.add(condition.Field__c);
                        query += ', ' + condition.Field__c;
                    }
                }
            }
            
            // Add FROM clause
            query += ' FROM ' + childObjectName;
            
            // Add WHERE clause
            query += ' WHERE ' + parentFieldName + ' IN :parentIds';
            
            // Add conditions if any
            if (conditions != null && !conditions.isEmpty()) {
                String conditionClause = buildWhereClause(conditions, logicType, customLogic);
                if (String.isNotBlank(conditionClause)) {
                    query += ' AND (' + conditionClause + ')';
                }
            }
            
            return query;
            
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error building query: ' + e.getMessage());
            return null;
        }
    }
    
    /**
     * @description Builds WHERE clause from child conditions
     */
    private static String buildWhereClause(
        List<Child_Condition__mdt> conditions, 
        String logicType, 
        String customLogic
    ) {
        if (conditions == null || conditions.isEmpty()) {
            return '';
        }
        
        List<String> conditionClauses = new List<String>();
        
        // Build individual condition clauses
        for (Child_Condition__mdt condition : conditions) {
            String clause = buildConditionClause(condition);
            if (String.isNotBlank(clause)) {
                conditionClauses.add(clause);
            }
        }
        
        if (conditionClauses.isEmpty()) {
            return '';
        }
        
        // Combine clauses based on logic type
        if (logicType == 'AND') {
            return String.join(conditionClauses, ' AND ');
        } else if (logicType == 'OR') {
            return String.join(conditionClauses, ' OR ');
        } else if (logicType == 'CUSTOM' && String.isNotBlank(customLogic)) {
            return buildCustomLogicClause(conditionClauses, customLogic);
        }
        
        // Default to AND
        return String.join(conditionClauses, ' AND ');
    }
    
    /**
     * @description Builds a single condition clause
     */
    private static String buildConditionClause(Child_Condition__mdt condition) {
        if (condition == null || String.isBlank(condition.Field__c)) {
            return '';
        }
        
        String field = String.escapeSingleQuotes(condition.Field__c);
        String operator = condition.Operator__c;
        String value = condition.Value__c;
        
        // Handle different operators
        if (operator == 'is null') {
            return field + ' = null';
        } else if (operator == 'is not null') {
            return field + ' != null';
        } else if (operator == 'equals') {
            return field + ' = ' + formatValue(value);
        } else if (operator == 'not equal to') {
            return field + ' != ' + formatValue(value);
        } else if (operator == 'contains') {
            return field + ' LIKE ' + formatLikeValue(value, true, true);
        } else if (operator == 'does not contain') {
            return '(NOT ' + field + ' LIKE ' + formatLikeValue(value, true, true) + ')';
        } else if (operator == 'greater than') {
            return field + ' > ' + formatValue(value);
        } else if (operator == 'less than') {
            return field + ' < ' + formatValue(value);
        }
        
        return '';
    }
    
    /**
     * @description Formats value for SOQL
     */
    private static String formatValue(String value) {
        if (value == null) {
            return 'null';
        }
        
        // Check if it's a boolean
        if (value.equalsIgnoreCase('true') || value.equalsIgnoreCase('false')) {
            return value.toLowerCase();
        }
        
        // Check if it's a number
        try {
            Decimal.valueOf(value);
            return value;
        } catch (Exception e) {
            // Not a number, treat as string
        }
        
        // Escape and quote string
        return '\'' + String.escapeSingleQuotes(value) + '\'';
    }
    
    /**
     * @description Formats value for LIKE operator
     */
    private static String formatLikeValue(String value, Boolean prefix, Boolean suffix) {
        if (value == null) {
            return '\'%\'';
        }
        
        String escaped = String.escapeSingleQuotes(value);
        String result = '\'';
        
        if (prefix) {
            result += '%';
        }
        result += escaped;
        if (suffix) {
            result += '%';
        }
        
        result += '\'';
        return result;
    }
    
    /**
     * @description Builds WHERE clause with custom logic
     */
    private static String buildCustomLogicClause(List<String> conditionClauses, String customLogic) {
        // This is a simplified implementation
        // For MVP, we'll support basic custom logic like "1 AND (2 OR 3)"
        String result = customLogic;
        
        // Replace condition numbers with actual clauses
        for (Integer i = 0; i < conditionClauses.size(); i++) {
            String conditionNumber = String.valueOf(i + 1);
            result = result.replace(conditionNumber, '(' + conditionClauses[i] + ')');
        }
        
        return result;
    }
    
    /**
     * @description Gets child object name from relationship name
     */
    private static String getChildObjectName(String relationshipName) {
        // This is a simplified implementation
        // In production, you'd use Schema methods to get the actual object name
        
        // Common patterns
        if (relationshipName.endsWith('__r')) {
            return relationshipName.substring(0, relationshipName.length() - 3) + '__c';
        } else if (relationshipName.endsWith('s')) {
            // Standard plural relationships (e.g., Contacts -> Contact)
            return relationshipName.substring(0, relationshipName.length() - 1);
        }
        
        return relationshipName;
    }
    
    /**
     * @description Gets parent field name from relationship
     */
    private static String getParentFieldName(String relationshipName) {
        // This is a simplified implementation
        // In production, you'd use Schema methods
        
        // For now, assume the parent field is the object name + 'Id'
        // e.g., for Contacts on Account, the field would be AccountId
        return 'AccountId'; // This should be dynamic based on actual relationship
    }
}
