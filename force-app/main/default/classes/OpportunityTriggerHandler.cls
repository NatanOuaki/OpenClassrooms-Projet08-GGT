/**
 * Infrastructure de routage pour OpportunityTrigger : ne contient aucune règle métier,
 * détecte le passage à Closed Won et délègue la création de Trip__c à TripService (GGT-02).
 */
public with sharing class OpportunityTriggerHandler {
    private final TripService tripService = new TripService();

    /**
     * Route les Opportunity venant de passer à Closed Won vers TripService.
     * @param updatedOpportunities Trigger.new pour un after update sur Opportunity.
     * @param previousOpportunityById Trigger.oldMap pour un after update sur Opportunity.
     */
    public void afterUpdate(List<Opportunity> updatedOpportunities, Map<Id, Opportunity> previousOpportunityById) {
        List<Opportunity> newlyClosedWonOpportunities = new List<Opportunity>();

        for (Opportunity updatedOpportunity : updatedOpportunities) {
            Opportunity previousOpportunity = previousOpportunityById.get(updatedOpportunity.Id);
            Boolean justClosedWon = updatedOpportunity.StageName == Constants.OPPORTUNITY_STAGE_CLOSED_WON
                && previousOpportunity.StageName != Constants.OPPORTUNITY_STAGE_CLOSED_WON;

            if (justClosedWon) {
                newlyClosedWonOpportunities.add(updatedOpportunity);
            }
        }

        if (!newlyClosedWonOpportunities.isEmpty()) {
            tripService.createTripsFromOpportunities(newlyClosedWonOpportunities);
        }
    }
}
