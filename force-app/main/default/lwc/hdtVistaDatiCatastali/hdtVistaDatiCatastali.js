import { LightningElement, api, wire } from 'lwc';
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

export default class HdtVistaDatiCatastali extends LightningElement {

    @api recordId;

    cols = COLUMNS;
    rows = [];
    title = 'Vista Dati Catastali';

    @wire(getVistaDatiCatastali, { recordId: '$recordId' })
    wiredVistaDatiCatastali({ error, result }) {
        if(result) {
            if(result.response.status == 'success'){
                let posizioni = result.response.data?.posizioni;
                let index = 0;
                let finalRows = [];
                posizioni.forEach(curPos => {
                    let newRow = curPos;
                    newRow.Id = index;
                    finalRows.push(newRow);
                    index++;
                })
                this.rows = finalRows;
                this.title = 'Vista Dati Catastali - ' + result.recordName;
                return;
            }
            if(result.response.status == 'failed'){
                return;
            }
            console.error('Cannot read response!');
        }
        else if(error) {
            console.error(JSON.stringify(error));
        }
    }
}