import { LightningElement, api, wire } from 'lwc';
import getVistaDatiCatastali from '@salesforce/apexContinuation/HDT_UTL_LandRegistry.getVistaDatiCatastali';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import CNT_NAME_FIELD from '@salesforce/schema/Contract.SAPContractCode__c';
import SVP_NAME_FIELD from '@salesforce/schema/ServicePoint__c.Name';


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

const CNT_FIELDS = [ CNT_NAME_FIELD ];
const SVP_FIELDS = [ SVP_NAME_FIELD ];
const SOBJ_FIELDS = { Contract: CNT_FIELDS, ServicePoint__c: SVP_FIELDS };
const SOBJ_NAME_FIELDS = { Contract: CNT_NAME_FIELD, ServicePoint__c: SVP_NAME_FIELD };
const SOBJ_LABELS = { Contract: 'Contratto', ServicePoint__c: 'Service Point' };

export default class HdtVistaDatiCatastali extends LightningElement {

    @api recordId;
    @api sObjectType;

    cols = COLUMNS;
    rows;
    title = 'Vista Dati Catastali';
    firstRenderDone = false;

    @wire(getRecord, { recordId: '$recordId', fields: SOBJ_FIELDS['$sObjectType'] })
    parentRecord;

    connectedCallback(){
        console.log('hadVistaDatiCatastali recordId:', this.recordId);
        if(this.recordId) {
            getVistaDatiCatastali({ recordId: this.recordId })
            .then( result => {
                if(result.status){
                    if(result.response.status == 'success'){
                        this.rows = [];
                        let posizioni = result.response.data?.posizioni;
                        let index = 0;
                        let finalRows = [];
                        posizioni.forEach(curPos => {
                            let newRow = JSON.parse(JSON.stringify(curPos));
                            newRow["Id"] = "tableRow_" + index;
                            finalRows.push(newRow);
                            index++;
                        })
                        this.rows = finalRows;
                        this.title = 'Vista Dati Catastali - ' + SOBJ_LABELS[this.sObjectType] + getFieldValue(this.parentRecord.data, SOBJ_NAME_FIELDS[this.sObjectType]);
                        return;
                    }
                    if(result.response.status == 'failed'){
                        return;
                    }
                }
                console.error('Cannot read response!');
            })
            .catch(error => {
                console.error(JSON.stringify(error));
            })
        }
    }
}