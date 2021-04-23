import { LightningElement, api, track, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

import SUBPROCESS from '@salesforce/schema/Case.Subprocess__c';



export default class HdtDocumentValidation extends LightningElement {


    @api recordId;

    @track isValidated;
    @track subprocess;
    @track columns;

    @track completeButton = 'Completa';
    @track closeButton = 'Chiudi';

    columnsAccise = [
        {id:1, name:'PersonalData' ,label:'Dati Anagrafici'},
        {id:2, name:'SupplyData', label: 'Dati Fornitura'},
        {id:3, name:'ServicePointCode', label: 'Matricola/PdR'},
        {id:4, name:'CraftsmenRegisterNumber', label: 'N. Iscrizione Albo Artigiani'},
        {id:5, name:'CheckActivityBox', label: 'Contr. casella attivita'},
        {id:6, name:'AssociationStatute', label: 'Statuto Ass./Atto Cost.'},
        {id:7, name:'Signature', label: 'Firma'},
        {id:8, name:'CciaaData', label: 'Dati CCIAA'},
        {id:9, name:'RequiredOfficeActivity', label: 'Attività Sede Richiesta'},
        {id:9, name:'IdentityDocument', label: 'Documento di Indentita'},
        {id:10, name:'IndustrialUsage', label: 'Comp. Mod. Rich. Aliquota Accise Usi Ind.'},
        {id:11, name:'SelfCertCciaa', label: 'Modulo Autocert. CCIAA'},
        {id:12, name:'AtecoCode', label: 'Codice ATECO'}
    ];

    columnsIva = [
        {id:1, name:'PersonalData' ,label:'Dati Anagrafici Legale Rapp. Azienda'},
        {id:2, name:'EconomicCode', label: 'Codice Attività Economica'},
        {id:3, name:'SupplyAddress', label: 'Indirizzo Fornitura'},
        {id:4, name:'ServicePointCode', label: 'Matricola Contatore/Presa Punto Fornitura'},
        {id:5, name:'SignatureInfo', label: 'Luogo Data Firma Legale Rapp.'},
        {id:6, name:'IdentiyDocCopy', label: 'Copia Documento Identità Legale Rapp.'},
        {id:7, name:'SchoolCategory', label: 'Categoria Scuola/Parrochie'},
        {id:8, name:'IncDenom', label: 'Denominazione Incongruente'},
        {id:9, name:'VatModule', label: 'Compilazione Modulo Iva 10'},
        {id:9, name:'AtecoCode', label: 'Codice Ateco'},
    ];

    @wire(getRecord, { recordId: '$recordId', fields: SUBPROCESS })
    wiredCase({error, data}){
        if(data){

            this.subprocess = getFieldValue(data, SUBPROCESS);

            console.log('LWC_Subprocess--> '+this.subprocess);

            if(this.subprocess!= null && this.subprocess.includes('IVA')){

                this.columns = this.columnsIva;

            } else {

                this.columns = this.columnsAccise;

            }

        }else if(error){

            console.log(error);

        }    

    }

    handleClick(event){

        if(event.target.name === 'complete'){

            let count = 0;

            let size = 0;

            this.template.querySelectorAll('lightning-input').forEach(element =>{

                ++size;

                console.log('element.value--> '+element.checked);

                if(element.checked){
                    ++count;
                }

            });

            if(count == size){

                this.isValidated = true;

            } else {

                this.isValidated = false;

            }

            const validated = this.isValidated;

            this.dispatchEvent(new CustomEvent('complete', {detail: { validated }}));

        } else {

            this.dispatchEvent(new CustomEvent('closeaction'));

        }

    }


   



}