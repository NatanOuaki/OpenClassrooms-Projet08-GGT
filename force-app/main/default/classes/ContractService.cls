/**
 * Logique métier et écritures (DML) relatives à l'objet Contract.
 */
public with sharing class ContractService {
    /**
     * Crée des Contract de façon bulkifiée, en appliquant le CRUD/FLS de l'utilisateur courant.
     * @param contractsToCreate Contract à insérer.
     */
    public void createContracts(List<Contract> contractsToCreate) {
        if (contractsToCreate.isEmpty()) {
            return;
        }
        SObjectAccessDecision decision = Security.stripInaccessible(AccessType.CREATABLE, contractsToCreate);
        insert decision.getRecords();
    }
}
