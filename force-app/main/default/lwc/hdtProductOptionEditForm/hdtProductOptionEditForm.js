import { LightningElement, api } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

export default class HdtProductOptionEditForm extends LightningElement {

    @api configuredSkuId;
    productOptionId;

    fieldsList = [
        'SBQQ__Number__c', 'SBQQ__Quantity__c',
        'SBQQ__QuantityEditable__c', 'SBQQ__Selected__c',
        'SBQQ__Feature__c', 'SBQQ__Type__c'
    ];

    handleLoad(event){
        console.log('>>>> handleLoad ');
    }

    handleSubmit(event){
      console.log('>>>> handleSubmit ');
      //event.preventDefault();
      //let fields = event.detail.fields; 
      //console.log(JSON.stringify(fields));
      //this.template.querySelector('lightning-record-edit-form').submit(fields);
    }

    handleSuccess(event) {
        try{
        console.log('>>>> handleSuccess');
        console.log('>>>> PRODUCT OPTION ID: ' + event.detail.id);

        const evt = new ShowToastEvent({
            title: "Prodotto opzione",
            message: "Configurazione eseguita correttamente",
            variant: "success"
        });
        this.dispatchEvent(evt);

        const saverecord = new CustomEvent("saverecord", {
            detail: {productOptionId: event.detail.id}
          });
    
          // Dispatches the event.
          this.dispatchEvent(saverecord);
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