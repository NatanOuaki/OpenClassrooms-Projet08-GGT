/**
 * Encapsule tout l'accès en lecture (SOQL) à l'objet Opportunity.
 */
public with sharing class OpportunitySelector {
    /**
     * Retourne les Opportunity correspondant aux Ids fournis, avec les champs
     * nécessaires au mapping GGT-02 vers Trip__c.
     * @param opportunityIds Ids d'Opportunity à charger.
     * @return Liste des Opportunity accessibles à l'utilisateur courant.
     */
    public List<Opportunity> selectByIds(Set<Id> opportunityIds) {
        List<Opportunity> opportunities = [
            SELECT Id, StageName, AccountId, Amount, Destination__c, Start_Date__c, End_Date__c, Number_of_Participants__c
            FROM Opportunity
            WHERE Id IN :opportunityIds
        ];
        SObjectAccessDecision decision = Security.stripInaccessible(AccessType.READABLE, opportunities);
        return decision.getRecords();
    }
}
