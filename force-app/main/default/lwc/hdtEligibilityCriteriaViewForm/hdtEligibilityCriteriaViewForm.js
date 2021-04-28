import { LightningElement, track, api } from 'lwc';

export default class HdtEligibilityCriteriaViewForm extends LightningElement {

    @api recordId;

    /*@track fieldsList = [
      'Channel__c',            'OriginMarket__c',
      'ClientMarker__c',       'CategoryTypeClient__c',
      'PromoCode__c',          'LoginGroup__c',
      'NewClient__c',          'ResidentDeliveryAddress__c',
      'Agency__c',             'CompanyOwner__c',
      'UseCategory__c',        'Campaign__c',
      'EquipmenType__c'
    ];
  
    @track complexFieldsList = [
      {fieldName: 'ClientAge', fields: ['ClientAgeMin__c', 'ClientAgeMax__c']},
      {fieldName: 'ConsumptionRangeEE', fields: ['ConsumptionRangeEEmin__c', 'ConsumptionRangeEEmax__c']},
      {fieldName: 'ConsumptionRangeGAS', fields: ['ConsumptionRangeGASmin__c', 'ConsumptionRangeGASmax__c']},
      {fieldName: 'PowerRange', fields: ['PowerRangeMin__c', 'PowerRangeMax__c']}
    ];*/

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

}