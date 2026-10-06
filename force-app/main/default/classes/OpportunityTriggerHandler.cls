/**
 * Infrastructure de routage pour OpportunityTrigger : dispatch() aiguille chaque événement
 * vers sa méthode dédiée. Les méthodes ne contiennent aucune règle métier : elles détectent
 * les enregistrements concernés et délèguent aux services (GGT-02 : TripService).
 */
public with sharing class OpportunityTriggerHandler {
    private final TripService tripService = new TripService();

    public void dispatch() {
        switch on Trigger.operationType {
            when BEFORE_INSERT {
                beforeInsert(Trigger.new);
            }
            when BEFORE_UPDATE {
                beforeUpdate(Trigger.new, (Map<Id, Opportunity>) Trigger.oldMap);
            }
            when BEFORE_DELETE {
                beforeDelete(Trigger.old);
            }
            when AFTER_INSERT {
                afterInsert(Trigger.new);
            }
            when AFTER_UPDATE {
                afterUpdate(Trigger.new, (Map<Id, Opportunity>) Trigger.oldMap);
            }
            when AFTER_DELETE {
                afterDelete(Trigger.old);
            }
            when AFTER_UNDELETE {
                afterUndelete(Trigger.new);
            }
        }
    }

    public void beforeInsert(List<Opportunity> newOpportunities) {
    }

    public void beforeUpdate(List<Opportunity> updatedOpportunities, Map<Id, Opportunity> previousOpportunityById) {
    }

    public void beforeDelete(List<Opportunity> deletedOpportunities) {
    }

    public void afterInsert(List<Opportunity> insertedOpportunities) {
    }

    /**
     * Route les Opportunity venant de passer à Closed Won vers TripService (GGT-02).
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

    public void afterDelete(List<Opportunity> deletedOpportunities) {
    }

    public void afterUndelete(List<Opportunity> undeletedOpportunities) {
    }
}
