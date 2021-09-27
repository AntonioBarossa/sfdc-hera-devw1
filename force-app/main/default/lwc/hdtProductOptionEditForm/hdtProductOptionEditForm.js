import { LightningElement, api } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import getFieldSet from '@salesforce/apex/HDT_LC_ProductAssociation.getFieldSet';
import { deleteRecord } from 'lightning/uiRecordApi';

export default class HdtProductOptionEditForm extends LightningElement {

    @api optionalSkuId;
    productOptionId;
    productOptionObj;
    spinner = true;

    fieldsList = [];

    connectedCallback(){
      this.getFieldSetList();
    }

    getFieldSetList(){
      getFieldSet({objApiName: 'SBQQ__ProductOption__c', fieldSetName: 'EditFormOnLwc'})
      .then(result => {
          console.log('>>> GET FIELD SET LIST');
          console.log('>>> ' + JSON.stringify(result));

          if(result.length>0){

            result.forEach((fieldApiName) => {
              this.fieldsList.push(fieldApiName);
            });

            this.spinner = false;
          } else {
            this.dispatchEvent(
              new ShowToastEvent({
                  title: 'Errore nel recupero dei dati',
                  message: error.message,
                  variant: 'error',
              }),
          );
          }

      })
      .catch(error => {
          console.log('# getFieldSet #');
          this.dispatchEvent(
              new ShowToastEvent({
                  title: 'Error while retriving fieldset',
                  message: error.message,
                  variant: 'error',
              }),
          );
      });
    }

    handleLoad(event){
        console.log('>>>> handleLoad ');
        //this.spinner = false;
    }

    handleSubmit(event){
      console.log('>>>> handleSubmit ');
      event.preventDefault();
      let fields = event.detail.fields; 
      //console.log(JSON.stringify(fields));
      fields.SBQQ__Number__c = 1;
      this.template.querySelector('lightning-record-edit-form').submit(fields);
    }

    handleSuccess(event) {
        try{
          console.log('>>>> handleSuccess');
          console.log('>>>> PRODUCT OPTION ID: ' + event.detail.id);

          this.productOptionId = event.detail.id;

          const evt = new ShowToastEvent({
              title: "Prodotto opzione",
              message: "Configurazione eseguita correttamente",
              variant: "success"
          });
          this.dispatchEvent(evt);

          var criteriaObj = {};
          this.template.querySelectorAll('lightning-input-field').forEach((field) => {
            criteriaObj[field.fieldName] = field.value;
          });
  
          var jsonRecord = JSON.stringify(criteriaObj);

          const saverecord = new CustomEvent("saverecord", {
            //detail: {productOptionId: event.detail.id}
            detail: {productOptionObj: jsonRecord}
          });
      
          // Dispatches the event.
          this.dispatchEvent(saverecord);
          this.delete();
        } catch (e){
            console.log('>>> ' + JSON.stringify(e));
        }
    }

    handleError(event){
        console.log('>>>> handleErrore ');
        console.log('>>>> ' + event.detail.message);
        console.log(JSON.stringify(event.detail.output.fieldErrors));
    }

    closeEditForm(){
        console.log('>>> closeEditForm');
        const closeEditForm = new CustomEvent("closeeditform", {
            detail: ''
          });
    
          // Dispatches the event.
          this.dispatchEvent(closeEditForm);
    }

    delete(event) {
      deleteRecord(this.productOptionId)
          .then(() => {
              console.log('>>>> RECORD DELETED');
          })
          .catch(error => {
              this.dispatchEvent(
                  new ShowToastEvent({
                      title: 'Error deleting record',
                      message: error.body.message,
                      variant: 'error'
                  })
              );
          });
    }

}