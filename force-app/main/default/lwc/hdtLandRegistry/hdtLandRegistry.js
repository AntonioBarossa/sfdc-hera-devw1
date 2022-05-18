import { LightningElement, api, track } from 'lwc';
import retrieveLandRegistry from '@salesforce/apex/HDT_UTL_LandRegistry.retrieveLandRegistry';

const columns = [
    { label: 'Codice assenza dati catastali',   fieldName: 'CodeMissingRegistryData__c',    type: 'text' },
    { label: 'Destinazione Uso',                fieldName: 'DestinationUsage__c',           type: 'text' },
    { label: 'Comune catastale',                fieldName: 'RegistryCity__c',               type: 'text' },
    { label: 'Codice comune catastale',         fieldName: 'RegistryCityCode__c',           type: 'text' },
    { label: 'Comune amministrativo',           fieldName: 'LegalCity__c',                  type: 'text' },
    { label: 'Provincia ubicazione',            fieldName: 'Province__c',                   type: 'text' },
    { label: 'Tipo unita',                      fieldName: 'UnitType__c',                   type: 'text' },
    { label: 'Sezione urbana',                  fieldName: 'UrbanSection__c',               type: 'text' },
    { label: 'Foglio',                          fieldName: 'Sheet__c',                      type: 'text' },
    { label: 'Particella',                      fieldName: 'ParticleSheet__c',              type: 'text' },
    { label: 'Subalterno',                      fieldName: 'Subaltern__c',                  type: 'text' },
    { label: 'Categoria Catastale',             fieldName: 'RegistryCategory__c',           type: 'text' },
    { label: 'Superficie Catastale',            fieldName: 'RegistrySurface__c',            type: 'text' },
    { label: 'Qualifica Titolare',              fieldName: 'Title__c',                      type: 'text' }   
];

export default class HdtLandRegistry extends LightningElement {
    
    @api servicePointId = 'a281X000000DmNZQA0';
    @api selectedLandRegistryId = '';
    @api required = false;
    @api readonly = false;
    @track data = [];
    @track selectedRows = [];
    showSpinner = false;
    
    connectedCallback(){
        console.log('### connectedCallback');
        //this.showSpinner = true;
        console.log('### selectedLandRegistryId= '+this.selectedLandRegistryId);
        console.log('### selectedRows= '+this.selectedRows);
        this.selectedRows.push(this.selectedLandRegistryId);
        //this.selectedRows = [this.selectedLandRegistryId];
        console.log('### selectedRows= '+this.selectedRows);
        this.getRetrieveLandRegistry();
    }

    getRetrieveLandRegistry() {
        console.log('### getRetrieveLandRegistry');
        this.showSpinner = true;
        this.data=[];
        retrieveLandRegistry({ servicePointIds : this.servicePointId })
            .then(result => {
                console.log('### retrieveLandRegistry');
                console.log('### result', JSON.stringify(result));
                this.data = result;
                this.showSpinner = false;
            });
            // .catch(error => {
            //     console.log("Errore: "+error);
            // });
    }

    // handleClick(event) {

    // }

}