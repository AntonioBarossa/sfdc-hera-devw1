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
    //  'SBQQ__Number__c',
    //  'SBQQ__Quantity__c',
    //  'SBQQ__QuantityEditable__c',
    //  'SBQQ__Selected__c',
    //  'SBQQ__Feature__c',
    //  'SBQQ__Type__c'
    //];

    connectedCallback(){
      this.getFieldSetList();
    }

    getFieldSetList(){
      getFieldSet({fieldSetName: 'Bonus_EE'})
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

    /*handleSubmitButtonClick(){
      console.log('>>>> handleSubmitButtonClick > ');
      var criteriaObj = {};
      this.template.querySelectorAll('lightning-input-field').forEach((field) => {
        criteriaObj[field.fieldName] = field.value;
      });

      //if(this.eligibilityId != undefined){
      //  criteriaObj.Id = this.eligibilityId;
      //}

      var checkResult = this.checkObjParameters(criteriaObj);

      if(checkResult.error){
        try{

          const evt = new ShowToastEvent({
              title: 'ATTENZIONE',
              message: checkResult.message,
              variant: 'warning'
          });
          this.dispatchEvent(evt);

        } catch(e){
          console.log('>>>>>>>>>>>>>>>> ERROR');
          console.log(e);
        }
      } else {
        var jsonRecord = JSON.stringify(criteriaObj);
        console.log(jsonRecord);
        const saverecord = new CustomEvent("saverecord", {
          detail: {record: jsonRecord}
        });
  
        // Dispatches the event.
        this.dispatchEvent(saverecord);
        //this.template.querySelector('lightning-record-edit-form').submit();
      }
    }

    checkObjParameters(obj){
      var checkResult = {};
      
      //console.log('>>>>>>>>>> ' + obj.CategoryTypeClient__c);

      //if(obj.CategoryTypeClient__c != null){
      //  var res = obj.CategoryTypeClient__c.split(";");
      //  
      //  if(res.length > 100){
      //    checkResult.error = true;
      //    checkResult.message = 'Non puoi selezionare più di 100 valori!';
      //    return checkResult;
      //  }
      //}

      checkResult.error = false;
      
      return checkResult;
    }*/

}