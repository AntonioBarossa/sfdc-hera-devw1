import { LightningElement, api, track, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LightningConfirm from 'lightning/confirm';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent, FlowNavigationFinishEvent, FlowNavigationBackEvent } from 'lightning/flowSupport';
import SUBPROCESS from '@salesforce/schema/Case.Subprocess__c';
import TYPE from '@salesforce/schema/Case.Type';
import COMMODITY from '@salesforce/schema/Case.Commodity__c';
import OUTCOME from '@salesforce/schema/Case.Outcome__c';
import NOTE from '@salesforce/schema/Case.PraxidiaNote__c';
import ID_FIELD from '@salesforce/schema/Case.Id';
import FASE from '@salesforce/schema/Case.Phase__c';
export default class HdtDocumentValidation extends LightningElement {
    @api recordId;
    @api saveInDraft;
    @api cancelCase;
    @api documentValidated;

    @track isValidated;
    @track subprocess;
    @track type;
    @track columns;

    @track completeButton = 'Completa';
    @track closeButton = 'Chiudi';
    @track disableButton = false;
    @track showSpinner = false;
    @track showWaste = false;
    @track noteValidation;
    @track valueWaste;
    optionsWaste = [
        { label: 'Documentazione completa', value: 'Documentazione completa' },
        { label: 'Documentazione incompleta di dati catastali', value: 'Documentazione incompleta di dati catastali' },
        { label: 'Documentazione incompleta di allegati', value: 'Documentazione incompleta di allegati' },
        { label: 'documentazione incompleta di più elementi', value: 'documentazione incompleta di più elementi' }
    ];
    notIntegratedProcess = ['DOM_Coabitazioni','Dati catastali','DOM_Componenti residenti','Variazione Indirizzo di Fornitura'];

    columnsAccise = [
        { id: 1, name: 'PersonalData', label: 'Dati Anagrafici' },
        { id: 2, name: 'SupplyData', label: 'Dati Fornitura' },
        { id: 3, name: 'ServicePointCode', label: 'Matricola/PdR' },
        { id: 4, name: 'CraftsmenRegisterNumber', label: 'N. Iscrizione Albo Artigiani' },
        { id: 5, name: 'CheckActivityBox', label: 'Contr. casella attivita' },
        { id: 6, name: 'AssociationStatute', label: 'Statuto Ass./Atto Cost.' },
        { id: 7, name: 'Signature', label: 'Firma' },
        { id: 8, name: 'CciaaData', label: 'Dati CCIAA' },
        { id: 9, name: 'RequiredOfficeActivity', label: 'Attività Sede Richiesta' },
        { id: 9, name: 'IdentityDocument', label: 'Documento di Indentita' },
        { id: 10, name: 'IndustrialUsage', label: 'Comp. Mod. Rich. Aliquota Accise Usi Ind.' },
        { id: 11, name: 'SelfCertCciaa', label: 'Modulo Autocert. CCIAA' },
        { id: 12, name: 'AtecoCode', label: 'Codice ATECO' }
    ];

    columnsIva = [
        { id: 1, name: 'PersonalData', label: 'Dati Anagrafici Legale Rapp. Azienda' },
        { id: 2, name: 'EconomicCode', label: 'Codice Attività Economica' },
        { id: 3, name: 'SupplyAddress', label: 'Indirizzo Fornitura' },
        { id: 4, name: 'ServicePointCode', label: 'Matricola Contatore/Presa Punto Fornitura' },
        { id: 5, name: 'SignatureInfo', label: 'Luogo Data Firma Legale Rapp.' },
        { id: 6, name: 'IdentiyDocCopy', label: 'Copia Documento Identità Legale Rapp.' },
        { id: 7, name: 'SchoolCategory', label: 'Categoria Scuola/Parrochie' },
        { id: 8, name: 'IncDenom', label: 'Denominazione Incongruente' },
        { id: 9, name: 'VatModule', label: 'Compilazione Modulo Iva 10' },
        { id: 9, name: 'AtecoCode', label: 'Codice Ateco' },
    ];

    @wire(getRecord, { recordId: '$recordId', fields: [SUBPROCESS,COMMODITY,OUTCOME,NOTE,TYPE] })
    wiredCase({ error, data }) {
        if (data) {
            this.subprocess = getFieldValue(data, SUBPROCESS);
            this.type = getFieldValue(data,TYPE);
            this.commodity = getFieldValue(data, COMMODITY);
            this.noteValidation = getFieldValue(data,NOTE);
            this.valueWaste = getFieldValue(data,OUTCOME);
            console.log('LWC_Subprocess--> ' + this.subprocess);
            if(this.commodity != null && this.commodity ==='Ambiente'){
                this.showWaste=true;
            }else{
                if (this.subprocess != null && this.subprocess.includes('IVA')) {
                    this.columns = this.columnsIva;
                } else {
                    this.columns = this.columnsAccise;
                }
            }
        } else if (error) {
            console.log(error);
        }
    }
    handleChange(event){
        this.valueWaste = event.detail.value;
    }
    async handleConfirmClick(recordInput) {
        const result = await LightningConfirm.open({
            message: 'Premendo OK verrà inviata la pratica verso i sistemi a valle, assicurati che la documentazione sia completa',
            variant: 'headerless',
            label: 'this is the aria-label value',
            // setting theme would have no effect
        });
        if(result){
            var record = recordInput;
            this.updateRecordCase(record,false,true);
            
        }else{
            this.showSpinner=false;
            this.dispatchEvent(new CustomEvent('closeaction'));
        }
    }

    handleFinalUpdate(){
        var nextPhase = this.notIntegratedProcess.includes(this.subprocess) || this.notIntegratedProcess.includes(this.type)?'In Lavorazione':'Da Inviare';
        const fields = {};
        fields[ID_FIELD.fieldApiName] = this.recordId;
        fields[FASE.fieldApiName] = nextPhase;
        var record = { fields };
        this.updateRecordCase(record,false,false);
    }
    updateRecordCase(recordInput,showMessage,finalUpdate){
        updateRecord(recordInput)
        .then(() => {
            if(showMessage){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Validazione Documentale aggiornata',
                        variant: 'success'
                    })
                );
            }
            if(finalUpdate){
                this.handleFinalUpdate();
            }else{
                //const validated = { isValidated: true, subprocess: null };
                //this.dispatchEvent(new CustomEvent('complete', { detail: { validated } }));
                this.showSpinner=false;
                this.dispatchEvent(new CustomEvent('closeaction'));
            }
        })
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Errore nell\' aggiornamento della validazione',
                    message: message,
                    variant: 'error'
                })
            );
        });
    }
    handleWasteComplete(){
        // Create the recordInput object
        const fields = {};
        fields[ID_FIELD.fieldApiName] = this.recordId;
        fields[OUTCOME.fieldApiName] = this.valueWaste;
        fields[NOTE.fieldApiName] = this.template.querySelector("lightning-textarea[data-id=noteWaste]").value;
        if(this.valueWaste === 'Documentazione completa'){
            fields[FASE.fieldApiName] = 'Documentazione validata';
            const recordInput = { fields };
            this.handleConfirmClick(recordInput);
        }else{
            const recordInput = { fields };
            this.updateRecordCase(recordInput,true,false);
        }
        const recordInput = { fields };        
    }

    handleClick(event) {
        this.showSpinner = true;
        this.disableButton = true;
        if (event.target.name === 'complete') {
            if(this.showWaste && this.valueWaste){
                this.handleWasteComplete();
            }else{
                let count = 0;
                let size = 0;
                this.template.querySelectorAll('lightning-input').forEach(element => {
                    ++size;
                    console.log('element.value--> ' + element.checked);
                    if (element.checked) {
                        ++count;
                    }
                });

                if (count === size) {
                    this.isValidated = true;
                } else {
                    this.isValidated = false;
                }
                const validated = { isValidated: this.isValidated, subprocess: this.subprocess };
                this.dispatchEvent(new CustomEvent('complete', { detail: { validated } }));
            }
            
        } else {
            this.showSpinner=false;
            this.dispatchEvent(new CustomEvent('closeaction'));
        }
    }
}