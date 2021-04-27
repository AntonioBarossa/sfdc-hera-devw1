import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class HdtEligibilityCriteriaParameters extends LightningElement {

    multiPicklistFields = [
      {fieldName: 'CategoryTypeClient__c', operator: 'CategoryTypeClientOperator__c'},
      {fieldName: 'Channel__c', operator: 'ChannelOperator__c'},
      {fieldName: 'OriginMarket__c', operator: 'OriginMarketOperator__c'},
      {fieldName: 'ClientMarker_c', operator: 'ClientMarkerOperator__c'},
      {fieldName: 'CompanyOwner__c', operator: 'CompanyOwnerOperator__c'}
    ];

    @track fieldsList = [
      'EquipmenType__c',
      'PromoCode__c',
      'LoginGroup__c',
      'NewClient__c',
      'ResidentDeliveryAddress__c',
      'Agency__c',
      'UseCategory__c',
      'Campaign__c'
    ];

    @track complexFieldsList = [
      {fieldName: 'ClientAge', fields: ['ClientAgeMin__c', 'ClientAgeMax__c']},
      {fieldName: 'ConsumptionRangeEE', fields: ['ConsumptionRangeEEmin__c', 'ConsumptionRangeEEmax__c']},
      {fieldName: 'ConsumptionRangeGAS', fields: ['ConsumptionRangeGASmin__c', 'ConsumptionRangeGASmax__c']},
      {fieldName: 'PowerRange', fields: ['PowerRangeMin__c', 'PowerRangeMax__c']}
    ];

    @api productid;
    @api eligibilityId;

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