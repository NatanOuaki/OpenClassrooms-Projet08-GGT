/**
 * Infrastructure de routage pour TripTrigger : dispatch() aiguille chaque événement vers sa
 * méthode dédiée. Les méthodes ne contiennent aucune règle métier : la cohérence des dates
 * (GGT-03) est déléguée à TripService.
 */
public with sharing class TripTriggerHandler {
    private final TripService tripService = new TripService();

    public void dispatch() {
        switch on Trigger.operationType {
            when BEFORE_INSERT {
                beforeInsert(Trigger.new);
            }
            when BEFORE_UPDATE {
                beforeUpdate(Trigger.new, (Map<Id, Trip__c>) Trigger.oldMap);
            }
            when BEFORE_DELETE {
                beforeDelete(Trigger.old);
            }
            when AFTER_INSERT {
                afterInsert(Trigger.new);
            }
            when AFTER_UPDATE {
                afterUpdate(Trigger.new, (Map<Id, Trip__c>) Trigger.oldMap);
            }
            when AFTER_DELETE {
                afterDelete(Trigger.old);
            }
            when AFTER_UNDELETE {
                afterUndelete(Trigger.new);
            }
        }
    }

    public void beforeInsert(List<Trip__c> newTrips) {
        tripService.validateDateConsistency(newTrips);
    }

    public void beforeUpdate(List<Trip__c> updatedTrips, Map<Id, Trip__c> previousTripById) {
        tripService.validateDateConsistency(updatedTrips);
    }

    public void beforeDelete(List<Trip__c> deletedTrips) {
    }

    public void afterInsert(List<Trip__c> insertedTrips) {
    }

    public void afterUpdate(List<Trip__c> updatedTrips, Map<Id, Trip__c> previousTripById) {
    }

    public void afterDelete(List<Trip__c> deletedTrips) {
    }

    public void afterUndelete(List<Trip__c> undeletedTrips) {
    }
}
