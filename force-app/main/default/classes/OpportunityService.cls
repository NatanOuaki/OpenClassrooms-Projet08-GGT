/**
 * Logique métier et écritures (DML) relatives à l'objet Opportunity.
 */
public with sharing class OpportunityService {
    /**
     * Crée des Opportunity de façon bulkifiée, en appliquant le CRUD/FLS de l'utilisateur courant.
     * @param opportunitiesToCreate Opportunity à insérer.
     */
    public void createOpportunities(List<Opportunity> opportunitiesToCreate) {
        if (opportunitiesToCreate.isEmpty()) {
            return;
        }
        SObjectAccessDecision decision = Security.stripInaccessible(AccessType.CREATABLE, opportunitiesToCreate);
        insert decision.getRecords();
    }
}
