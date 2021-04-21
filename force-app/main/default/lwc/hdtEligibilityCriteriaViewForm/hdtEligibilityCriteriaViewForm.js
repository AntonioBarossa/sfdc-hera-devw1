import { LightningElement, track, api } from 'lwc';

export default class HdtEligibilityCriteriaViewForm extends LightningElement {

    @api recordId;

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

}