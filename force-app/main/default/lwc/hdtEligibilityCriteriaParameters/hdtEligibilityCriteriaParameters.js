import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class HdtEligibilityCriteriaParameters extends LightningElement {

    @track fieldsList = [
      'Channel__c',            'OriginMarket__c',
      'ClientMarker__c',       'CategoryTypeClient__c',
      'Login__c',              'LoginGroup__c',
      'NewClient__c',          'ResidentDeliveryAddress__c',
      'Agency__c',             'CompanyOwner__c',
      'UseCategory__c',        'Campaign__c',
      'EquipmenType__c',       'PromoCode__c'
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

      var jsonRecord = JSON.stringify(criteriaObj);
      console.log(jsonRecord);
      const saverecord = new CustomEvent("saverecord", {
        detail: {record: jsonRecord}
      });

      // Dispatches the event.
      this.dispatchEvent(saverecord);
      //this.template.querySelector('lightning-record-edit-form').submit();
    }

    /*@track fields = [
       {row: '1', innerList: ['Agenzia', 'Marcatura Cliente']},
       {row: '2', innerList: ['ATC Gas', 'Nuovo Cliente']},
       {row: '3', innerList: ['Campagna', 'Opzione Energia Verde']},
       {row: '4', innerList: ['Canale', 'Opzione Gas Verde']},
       {row: '6', innerList: ['Codice Criterio', 'Provenienza']},
       {row: '7', innerList: ['Company Owner', 'Raggruppamento di Login']},
       {row: '8', innerList: ['Eta Cliente', 'Ruolo Profilo']},
       {row: '9', innerList: ['Fascia', 'Tipo Apparecchiatura']},
       {row: '10', innerList: ['Login', 'Tipo Cliente Categoria']}
    ];*/

    /*@track fieldsList = [
        {
          id: '1',
          list: [
            'Channel__c',
            'Agency__c',
            'Login__c',
            'LoginGroup__c',
            'ClientMarker__c',
            'CategoryTypeClient__c',
            'NewClient__c',
            'CompanyOwner__c',
            'ClientAge__c',
            'Campaign__c'
          ]
        },
        {
          id: '2',
          list: [
            'EquipmenType__c',
            'UseCategory__c',
            'ConsumptionRangeEE__c',
            'ConsumptionRangeGAS__c',
            'PowerRange__c',
            'OriginMarket__c',
            'ResidentDeliveryAddress__c'//,
            ///'PaymentMode__c',
            ///'BillSendingMethod__c'
          ]
        }
      ];*/

}