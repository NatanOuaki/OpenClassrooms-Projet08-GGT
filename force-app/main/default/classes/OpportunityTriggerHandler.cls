/**
 * Infrastructure de routage pour OpportunityTrigger : dispatch() aiguille chaque événement
 * vers sa méthode dédiée. Les méthodes ne contiennent que des appels aux services : aucune
 * condition, aucune boucle, aucune règle métier (GGT-02 : TripService).
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

    public void afterUpdate(List<Opportunity> updatedOpportunities, Map<Id, Opportunity> previousOpportunityById) {
        tripService.createTripsForNewlyClosedWonOpportunities(updatedOpportunities, previousOpportunityById);
    }

    public void afterDelete(List<Opportunity> deletedOpportunities) {
    }

    public void afterUndelete(List<Opportunity> undeletedOpportunities) {
    }
}
