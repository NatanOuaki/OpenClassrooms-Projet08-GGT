/**
 * Encapsule tout l'accès en lecture (SOQL) à l'objet Contract.
 */
public with sharing class ContractSelector {
    /**
     * Retourne les Contract correspondant aux Ids fournis.
     * @param contractIds Ids de Contract à charger.
     * @return Liste des Contract accessibles à l'utilisateur courant.
     */
    public List<Contract> selectByIds(Set<Id> contractIds) {
        List<Contract> contracts = [
            SELECT Id, AccountId, StartDate, ContractTerm, EndDate, Status
            FROM Contract
            WHERE Id IN :contractIds
        ];
        SObjectAccessDecision decision = Security.stripInaccessible(AccessType.READABLE, contracts);
        return decision.getRecords();
    }
}
