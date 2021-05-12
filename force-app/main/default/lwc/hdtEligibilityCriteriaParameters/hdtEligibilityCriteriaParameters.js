import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class HdtEligibilityCriteriaParameters extends LightningElement {

    @api productid;
    @api eligibilityId;

    multiPicklistFields = [
      {label: 'Tipo Cliente Categoria', fieldName: 'CategoryTypeClient__c', operator: 'CategoryTypeClientOperator__c'},
      {label: 'Canale', fieldName: 'Channel__c', operator: 'ChannelOperator__c'},
      {label: 'Mercato Provenienza', fieldName: 'OriginMarket__c', operator: 'OriginMarketOperator__c'},
      {label: 'Marcatura Cliente', fieldName: 'ClientMarker__c', operator: 'ClientMarkerOperator__c'},
      {label: 'Company Owner', fieldName: 'CompanyOwner__c', operator: 'CompanyOwnerOperator__c'}
    ];

    fieldsList = [
      'EquipmenType__c',            'PromoCode__c',
      'ResidentDeliveryAddress__c', 'NewClient__c',
      'LoginGroup__c',              'Agency__c',
      'UseCategory__c',             'CampaignName__c'
    ];

    complexFieldsList = [
      {fieldName: 'ClientAge', fields: ['ClientAgeMin__c', 'ClientAgeMax__c']},
      {fieldName: 'PowerRange', fields: ['PowerRangeMin__c', 'PowerRangeMax__c']},
      {fieldName: 'ConsumptionRangeEE', fields: ['ConsumptionRangeEEmin__c', 'ConsumptionRangeEEmax__c']},
      {fieldName: 'ConsumptionRangeGAS', fields: ['ConsumptionRangeGASmin__c', 'ConsumptionRangeGASmax__c']}
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
        console.log('>>>> handleSuccess');

        const evt = new ShowToastEvent({
            title: "Product created",
            message: "Record ID: " + event.detail.id,
            variant: "success"
        });
        this.dispatchEvent(evt);
    }

    handleError(event){
        console.log('>>>> handleErrore ');
        console.log('>>>> ' + event.detail.message);
        console.log(JSON.stringify(event.detail.output.fieldErrors));
    }

    @api handleSubmitButtonClick(){
      console.log('>>>> handleSubmitButtonClick > ');
      var criteriaObj = {};
      this.template.querySelectorAll('lightning-input-field').forEach((field) => {
        criteriaObj[field.fieldName] = field.value;
      });

      if(this.eligibilityId != undefined){
        criteriaObj.Id = this.eligibilityId;
      }

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
      
      console.log('>>>>>>>>>> ' + obj.CategoryTypeClient__c);

      if(obj.CategoryTypeClient__c != null){
        var res = obj.CategoryTypeClient__c.split(";");
        
        if(res.length > 100){
          checkResult.error = true;
          checkResult.message = 'Non puoi selezionare più di 100 valori!';
          return checkResult;
        }
      }

      checkResult.error = false;
      
      return checkResult;
    }

}