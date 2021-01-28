import { LightningElement, api, wire } from 'lwc';
import insertDocuments from '@salesforce/apex/HDT_LC_AddDocumentSelected.insertDocuments'
import checkExistingDocuments from '@salesforce/apex/HDT_LC_AddDocumentSelected.checkExistingDocuments'
import { ShowToastEvent } from 'lightning/platformShowToastEvent'

export default class HdtAggiungiDocumento extends LightningElement {
    @api recordId;

    documentCounter = 0;

    datiInvioEC = [];

    documenti=[];

    selectableDocuments=[]

    selectedDocument=[];

    editor = false;

    checks = false;

    isLoading = false;

    isNull = false;

    datiInput = [

        {label:'Codice Business Partner', type:'text'},
        {label:'Contract Account', type:'text'},
        {label:'Data da', type:'date'},
        {label:'Data a', type:'date'},
        {label:'Bollettino', type:'text'},
        {label:'Riferimento fattura', type:'text'},
        {label:'Estrazione di sole partite aperte', type:'text'}

    ];

    handleClick(){

        var inputs = this.template.querySelectorAll("lightning-input");

        this.isLoading = true;

        inputs.forEach(element =>{

            this.datiInvioEC.push(element.value);

        });

        //console.log(this.datiInvioEC);

        //console.log(this.editor);

        this.datiInvioEC = [];

        for(let i=0; i<100; ++i){

            this.documenti.push({Id: i, label: 'documento '+i});

        }

        checkExistingDocuments({documents: this.documenti.label, caseId: this.recordId}).then(results =>{

            results.forEach(element =>{

                let index = this.documenti.findIndex(x => x.label.includes(element));

                this.documenti.splice(index,1);

                //console.log(this.documenti);

            })

            //console.log(this.documenti.length);

            this.isLoading = false;
    
            if(this.documenti.length == 0){

                this.isNull = true;

            }

            this.editor = true;
        
        }).catch(error =>{

            console.log(error);

        });


        
    }

    get options(){

        return [{label: 'Seleziona Tutto', value: 'Seleziona Tutto'}]

    }

    handleSelectAll(){

        var checks = this.template.querySelectorAll("lightning-input");

        this.checks = !this.checks;

        checks.forEach(element =>{

            element.checked = this.checks;

        });

    }

    handleDocument(){

        console.log(this.datiInvioEC);

        var checks = this.template.querySelectorAll("lightning-input");

        checks.forEach(element =>{
              
                if(element.checked){

                    //console.log(element.label);

                    this.selectedDocument.push(element.label);

                    ++this.documentCounter;

                }

        });

        insertDocuments({documents: this.selectedDocument, caseId: this.recordId}).then(result =>{

            //console.log('documenti inseriti');
            console.log(result);

            this.dispatchEvent(new CustomEvent('close', {detail: this.documentCounter + ' Documenti Inseriti'}));

        }).catch(error =>{

            //console.log('documenti non inseriti');
            console.log(error);

        });

        this.documenti = [];

        this.selectedDocument = [];

        this.editor = false;

        //console.log(this.editor);

    }

    handleBackToStart(){

        this.isNull = false;

        this.editor = false;

    }

}