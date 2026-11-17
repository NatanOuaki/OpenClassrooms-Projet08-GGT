/**
 * Classe utilitaire de test : centralise la création des Opportunity utilisées par les tests.
 * Annotée @isTest, elle n'est utilisable que depuis du code de test et ne compte pas dans
 * la limite de taille du code Apex de l'org.
 */
@isTest
public class TestDataFactory {
    /**
     * Construit, sans l'insérer, une Opportunity avec les informations de voyage.
     * @param accountId Compte client de l'Opportunity.
     * @param name Nom de l'Opportunity.
     * @param stageName Stade de l'Opportunity (ex. Prospecting, Closed Won).
     * @param amount Montant ; peut être null.
     * @param destination Destination du voyage ; peut être null.
     * @param startDate Date de début du voyage ; peut être null.
     * @param endDate Date de fin du voyage ; peut être null.
     * @param numberOfParticipants Nombre de participants ; peut être null.
     * @return L'Opportunity non insérée.
     */
    public static Opportunity buildTripOpportunity(
        Id accountId,
        String name,
        String stageName,
        Decimal amount,
        String destination,
        Date startDate,
        Date endDate,
        Decimal numberOfParticipants
    ) {
        return new Opportunity(
            Name = name,
            AccountId = accountId,
            StageName = stageName,
            CloseDate = Date.today(),
            Amount = amount,
            Destination__c = destination,
            Start_Date__c = startDate,
            End_Date__c = endDate,
            Number_of_Participants__c = numberOfParticipants
        );
    }

    /**
     * Crée et insère une Opportunity avec les informations de voyage.
     * @return L'Opportunity insérée.
     */
    public static Opportunity createTripOpportunity(
        Id accountId,
        String name,
        String stageName,
        Decimal amount,
        String destination,
        Date startDate,
        Date endDate,
        Decimal numberOfParticipants
    ) {
        Opportunity opportunity = buildTripOpportunity(
            accountId,
            name,
            stageName,
            amount,
            destination,
            startDate,
            endDate,
            numberOfParticipants
        );
        insert opportunity;
        return opportunity;
    }

    /**
     * Crée et insère une Opportunity simple, sans informations de voyage.
     * @return L'Opportunity insérée.
     */
    public static Opportunity createOpportunity(Id accountId, String name, String stageName, Decimal amount) {
        return createTripOpportunity(accountId, name, stageName, amount, null, null, null, null);
    }
}
