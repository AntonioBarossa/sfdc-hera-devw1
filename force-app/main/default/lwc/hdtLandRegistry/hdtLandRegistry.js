import { LightningElement, track, api, wire } from 'lwc';
import retrieveLandRegistryByServicePointId from '@salesforce/apex/HDT_UTL_LandRegistry.retrieveLandRegistryByServicePointId';

export default class HdtLandRegistry extends LightningElement {
    
    @api servicePoint;
    @api selectedLandRegistry;
    @api required = false;
    @api readonly = false;

    const COLS = [
        { label: 'Codice assenza dati catastali', fieldName: 'CodeMissingRegistryData__c', type: 'text' },
        { label: 'Destinazione Uso', fieldName: 'DestinationUsage__c', type: 'text' },
        { label: 'Comune catastale', fieldName: 'RegistryCity__c', type: 'text' },
        { label: 'Codice comune catastale', fieldName: 'RegistryCityCode__c', type: 'text' },
        { label: 'Comune amministrativo', fieldName: 'LegalCity__c', type: 'text' },
        { label: 'Stage', fieldName: 'Province__c', type: 'text' },
        { label: 'Stage', fieldName: 'UnitType__c', type: 'text' },
        { label: 'Stage', fieldName: 'UrbanSection__c', type: 'text' },
        { label: 'Stage', fieldName: 'Sheet__c', type: 'text' },
        { label: 'Stage', fieldName: 'ParticleSheet__c', type: 'text' },
        { label: 'Stage', fieldName: 'Subaltern__c', type: 'text' },
        { label: 'Stage', fieldName: 'RegistryCategory__c', type: 'text' },

        { label: 'Stage', fieldName: 'RegistrySurface__c', type: 'text' },
        // { label: 'Stage', fieldName: 'RegistryCategory__c', type: 'text' }, --> AGG campo mancante!
        { label: 'Stage', fieldName: 'Title__c', type: 'text' }
        
    ];

    connectedCallback() {


        retrieveLandRegistryByServicePointId();
    }

}