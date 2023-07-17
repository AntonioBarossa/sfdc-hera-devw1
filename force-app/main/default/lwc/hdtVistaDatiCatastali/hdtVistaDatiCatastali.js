import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getVistaDatiCatastali from '@salesforce/apexContinuation/HDT_UTL_LandRegistry.getVistaDatiCatastali';

const COLUMNS = [
    { fieldName: 'destinazioneUso', label: 'Destinazione Uso' },
    { fieldName: 'codiceAssenzaDatiCatastali', label: 'Codice Assenza Dati Catastali' },
    { fieldName: 'comuneAmministrativo', label: 'Comune Amministrativo' },
    { fieldName: 'comuneCatastale', label: 'Comune Catastale' },
    { fieldName: 'codiceComuneCatastale', label: 'Codice Comune Catastale' },
    { fieldName: 'codiceProvincia', label: 'Codice Provincia' },
    { fieldName: 'tipoUnita', label: 'Tipo Unità' },
    { fieldName: 'sezioneUrbana', label: 'Sezione Urbana' },
    { fieldName: 'foglio', label: 'Foglio' },
    { fieldName: 'particella', label: 'Particella' },
    { fieldName: 'subalterno', label: 'Subalterno' },
    { fieldName: 'qualificaTitolareUtenza', label: 'Qualifica Titolare' },
    { fieldName: 'superficieCatastale', label: 'Superficie Catastale' },
    { fieldName: 'categoriaCatastale', label: 'Categoria Catastale' }
];

const SOBJ_LABELS = { Contract: 'Contratto', ServicePoint__c: 'Service Point' };

export default class HdtVistaDatiCatastali extends LightningElement {

    @api recordId;
    @api sObjectType;

    title = 'Vista Dati Catastali';
    cols = COLUMNS;
    rows;
    showSpinner = true;

    connectedCallback(){
        console.log('>>recordId:', this.recordId);
        console.log('>>sObjectType:', this.sObjectType);
        if(this.recordId && this.sObjectType) {
            this.title = 'Vista Dati Catastali - ' + SOBJ_LABELS[this.sObjectType];
            getVistaDatiCatastali({ recordId: this.recordId })
            .then( result => {
                if(result.status){
                    this.rows = [];
                    let posizioni = result.rows;
                    let index = 0;
                    let finalRows = [];
                    posizioni.forEach(curPos => {
                        let newRow = JSON.parse(JSON.stringify(curPos));
                        newRow["Id"] = "tableRow_" + index;
                        finalRows.push(newRow);
                        index++;
                    })
                    this.rows = finalRows;

                    if(this.rows.length == 0){
                        const event = new ShowToastEvent({
                            title: result.status,
                            message: result.message,
                            variant: result.status == 'KO' ? 'error' : 'warning',
                            mode: 'dismissable'
                        });
                        this.dispatchEvent(event);
                    }
                }
                console.error('Cannot read response!');
            })
            .catch(error => {
                console.error(JSON.stringify(error));
            })
            .finally(()=>{
                this.showSpinner = false;
            })
        }
    }
}