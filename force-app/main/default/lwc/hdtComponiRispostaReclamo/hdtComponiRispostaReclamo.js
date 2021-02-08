import { LightningElement, api, wire } from 'lwc';
import buildRisposta from '@salesforce/apex/HDT_UTL_ComponiRispostaReclamo.buildRisposta';
import { FlowNavigationNextEvent, FlowNavigationFinishEvent } from 'lightning/flowSupport';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { refreshApex } from '@salesforce/apex';
import { updateRecord } from 'lightning/uiRecordApi';

import QUARTO_LIVELLO from '@salesforce/schema/Case.evr_QuartoLivello__c';
import ARGOMENTO from '@salesforce/schema/evr_TemplateRisposta__c.evr_Argomento__c'

const fields = [QUARTO_LIVELLO];

const columns =[

    {label: 'Nome Template', fieldName: 'name', type: 'Text'},
    {
        type: 'customRowAction',
        fieldName:'id',
        typeAttributes: {
            recordId: { fieldName: 'id' }
        }
    }

];

export default class HdtProva extends LightningElement {

    @api recordId;

    @api availableActions = [];
    
    data = [];

    selectedContent = [];

    filterList = [
        {value: 'all', label: 'All'},
        {value: 'fourth', label: '4° Livello'}
    ];

    filterValue = '';

    filter = '';

    columns = columns;

    textPreview = '';

    quartoLivello = '';

    showSelected = false;

    openModal = false;

    buttonCompose = false;

    //showButtonLabel = 'Mostra Corpo Risposta'

    //showCorpoRisposta = false;

    loadingSpinner = false;

    delay = 500;

    @wire(getRecord, { recordId: '$recordId', fields: fields })
    wiredCase({error, data}){
        if(data){

            this.quartoLivello = getFieldValue(data, QUARTO_LIVELLO);

            console.log(this.quartoLivello);

        }else if(error){

            console.log(error);

        }    

    }

    @wire(getPicklistValues,{recordTypeId: '012000000000000AAA', fieldApiName: ARGOMENTO})
    wiredPicklist({error,data}){
        if(data){

            console.log(data.values);

            data.values.forEach(element => {

                this.filterList = [...this.filterList,{value: element.label, label: element.label}];

            });

            console.log(this.filterList);

        } else if(error){

            console.log(error)

        }

    }

    get options(){

        return this.filterList;

    }

    handleFilter(event){

        if(event.detail.value === 'all'){

            this.filter = '';

        } else if(event.detail.value === 'fourth'){

            this.filter = 'evr_QuartoLivello__c INCLUDES (\'' + this.quartoLivello + '\')';

        } else{

            this.filter = 'evr_Argomento__c LIKE \'%' + event.detail.value + '%\'';

        }

    }


    handleSelection(event){

        console.log('selected'); 
        
        console.log('Id selezionato: '+event.detail.selectedId);
        console.log('Template selezionato: '+event.detail.name);
        console.log('Contenuto selezionato: '+event.detail.code);


        this.data = [...this.data,{id: event.detail.selectedId, name: event.detail.name, content: event.detail.code}];
        
        console.log(this.data);

        this.showSelected = true;

        this.buttonCompose = true;
        
    }

    handleRowAction(event){

        const actionName = event.detail.eventName;
        const templateId = event.detail.recordId;
        console.log('Evento :' +event.detail.recordId);
        console.log(actionName);
        switch (actionName) {
            case 'delete':
                    this.handleRemove(templateId);
                break;
            case 'preview':
                    this.filePreview(templateId);

            default:
        }

    }

    handleRemove(templateId){

        let index = this.data.findIndex(obj => obj.Id === templateId );

        this.data.splice(index,1);

        this.data = [...this.data];
        
        if(this.data.length == 0){

            this.buttonCompose = false;

        }

    }

    deleteTemplates(){

        this.data = [];

        this.buttonCompose = false;

    }

    filePreview(templateId){

        this.openModal = true;

        var objPreview = this.data.find( obj =>{

            return obj.id === templateId;

        });

        console.log('Oggetto filtrato: '+objPreview.content);

        this.textPreview = objPreview.content;

    }

    closeModal() {

        this.openModal = false;
    
    } 

    /*handleClickShow(){

        if(this.showCorpoRisposta == false){

            this.showCorpoRisposta = true;

            this.showButtonLabel = 'Nascondi Corpo Risposta';

        } else {

            this.showCorpoRisposta = false;

            this.showButtonLabel = 'Mostra Corpo Risposta';

        }

    }*/

    handleCompose(event){

        this.loadingSpinner = true;

        console.log(event.target.name);

        if(event.target.name === 'delete all'){

            buildRisposta({templates: this.selectedContent, recordId: this.recordId, deleteAll: true})
        .then(results => {

            console.log(results);    

            this.refreshValues(this.recordId);

            setTimeout(() => {

                this.loadingSpinner = false;
            
            }, this.delay);
            

            //this.showButtonLabel = 'Nascondi Corpo Risposta';

        }).catch(error =>{

            console.log(error);

        });
            
        } else {

            this.data.forEach(element =>{

                this.selectedContent.push(element.content);

            });

            buildRisposta({templates: this.selectedContent, recordId: this.recordId, deleteAll: false})
            .then(results => {

                console.log(results);    

                this.refreshValues(this.recordId);
            
                setTimeout(() => {

                    this.loadingSpinner = false;
                
                }, this.delay);

                //this.showButtonLabel = 'Nascondi Corpo Risposta';

            }).catch(error =>{

                console.log(error);

            });

            this.selectedContent = [];

        }

    }

    refreshValues(recordId) {

        updateRecord({fields: { Id: recordId }});

        /*const inputFields = this.template.querySelectorAll('lightning-input-field');
        if (inputFields) {
            inputFields.forEach((field) => {
                field.reset();
            });
        }*/

        //return refreshApex();

    }

    handleSuccess(){

        //since this class is referenced in the .html need to exist or system will throw an unblocking 
        //"Uncaught Error: Cannot read property 'apply' of undefined"

    }

    handleSubmit(){

        console.log('Submit Success');

        if(this.availableActions.find(action => action === 'NEXT')){

            const navigateNextEvent = new FlowNavigationNextEvent();

            this.dispatchEvent(navigateNextEvent);

        } else {

            const navigateFinish = new FlowNavigationFinishEvent();

            this.dispatchEvent(navigateFinish);

        }
    }


    copyToClip() {

        var str = this.template.querySelector('lightning-input-field').value;

        function listener(e){
          e.clipboardData.setData("text/html", str);
          e.clipboardData.setData("text/plain", str);
          e.preventDefault();
        }
        document.addEventListener("copy", listener);
        document.execCommand("copy");
        document.removeEventListener("copy", listener);
      }
    
}