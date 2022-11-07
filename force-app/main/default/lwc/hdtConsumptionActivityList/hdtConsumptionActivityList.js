import { LightningElement, api, track, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getRecordsFromWs from '@salesforce/apexContinuation/HDT_LC_ConsActivityListController.startRequest';
import getConfigurationData from '@salesforce/apex/HDT_LC_ConsActivityListController.getTableConfig';
import CONTRACT_NUMBER from '@salesforce/schema/Contract.SAPContractCode__c';

const firstColumn = [
    {
        label: '',
        type: 'button',
        initialWidth: 160,
        typeAttributes: {
                            label: 'Vedi Consumi',
                            title: 'Seleziona',
                            variant: 'border-filled',
                            alternativeText: 'Seleziona'
                        }
    }
];

const FIELDS = ['Contract.SAPContractCode__c'];

export default class HdtConsumptionActivityList extends LightningElement {
    
    @api recordId;
    @api tabType;
    @track contractColumns = [];
    detailColumns;
    detailsDataToView = [];
    @track contractNumber;
    @track meterReadingColumns;
    hideCheckboxColumn = true;
    loadData = false;
    queryTerm = '';
    spinner = true;
    error = false;
    showDetailTable = false;
    hasDetailTable = false;
    showTimeButton = false;
    showFilter = false;
    openModal = false;
    errorMessage = '';
    contractData = [];
    contractDataToView = [];
    sortDirection = 'desc';
    sortedBy;
    contract;
    requestObj = {};
    mainTitle;
    mainIcon;
    detailTitle;
    detailIcon;
    buttonGroup = [];
    modalHeader;
    modalBody;
    parameter;
    buttonName;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredRecord({ error, data }) {
        if (error) {
            let message = 'Unknown error';
            if (Array.isArray(error.body)) {
                message = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                message = error.body.message;
            }
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading contract',
                    message,
                    variant: 'error',
                }),
            );
        } else if (data) {
            this.contractNumber = getFieldValue(data, CONTRACT_NUMBER);
            console.log('>>> data ' + JSON.stringify(data));
            console.log('>>> ContractNumber > ' + this.contractNumber);
            console.log('>>> ContractId > ' + this.recordId);
            console.log('>>> tabType > ' + this.tabType);
            this.setRequestObj();
            this.configurationData();
        }
    }

    focusOnButton(thisButton){
        this.template.querySelectorAll('slds-button').forEach((but) => {
            but.classList.remove('slds-button_brand');
            but.classList.add('slds-button_neutral');
            if(but.name === thisButton){
                but.classList.add('slds-button_brand');
            }            
        });
    }

    setRequestObj() {

        switch (this.tabType) {

            case "consumptionList2g"://Elenco Consumi 2G
                this.requestObj.contractCode = this.contractNumber;
                this.requestObj.date = this.setMyDate(-2);//'2022-05-28, --TODAY - 2 GG';
                this.requestObj.idAggregation = 'D';
                this.buttonGroup.push({name: 'dayly', type: '', parameters: 'D', label: 'Giornaliero'});
                this.buttonGroup.push({name: 'weekly', type: '', parameters: 'W', label: 'Settimanale'});
                this.buttonGroup.push({name: 'monthly', type: '', parameters: 'M', label: 'Mensile'});
                this.showTimeButton = true;
            break;

            case "activityList2g": //Elenco Attività 2G
                this.requestObj.dateFrom = this.setMyDate(-7);//'2022-05-19, TODAY - 7';
                this.requestObj.dateTo = this.setMyDate(0);//'2022-05-07, TODAY';
                this.requestObj.idService = 'D';
                this.requestObj.contractCode = this.contractNumber;
                this.buttonGroup.push({name: 'filter', type: '', parameters: 'filter', label: 'Filtri'});
                this.showFilter = true;
            break;
        }

    }

    setMyDate(days){
        var today = new Date();
        var date = '';
        today.setDate(today.getDate() + days);

        var dd = String(today.getDate()).padStart(2, '0');
        var mm = String(today.getMonth() + 1).padStart(2, '0');
        var yyyy = today.getFullYear();
        
        date = yyyy + '-' + mm + '-' + dd;
        console.log('>>> date > ' + date);
        return date;
    }

    configurationData(){
        getConfigurationData({type: this.tabType})
        .then(result => {

            if(result.success){

                switch (this.tabType) {

                    case "consumptionList2g"://Elenco Consumi 2G
                        this.contractColumns = firstColumn.concat(result.tables[0].columns);
                        this.contractColumns = this.contractColumns.concat(result.tables[0].columns);
                        this.mainTitle = result.tables[0].tableTitle;
                        this.mainIcon = result.tables[0].iconName;
                        this.detailColumns = result.tables[1].columns;
                        this.detailTitle = result.tables[1].tableTitle;
                        this.detailIcon = result.tables[1].iconName;
                        this.hasDetailTable = true;
                        this.showDetailTable = true;
                    break;
        
                    case "activityList2g": //Elenco Attività 2G
                        this.contractColumns = this.contractColumns.concat(result.tables[0].columns);
                        this.mainTitle = result.tables[0].tableTitle;
                        this.mainIcon = result.tables[0].iconName;
                    break;
                }

                this.backendCall();

            } else {
                console.log('>>>> ERROR > getContractRecords');
                this.error = true;
                this.errorMessage = result.message;
                this.spinner = false;                
            }

        }).catch(error => {
            console.log('>>>> ERROR - catch');
            console.log(error);
        });
    }

    backendCall(){
        console.log('# Get data from WS #');
        console.log('>>> request: ' + JSON.stringify(this.requestObj));
        
        //this.setMockData();

        getRecordsFromWs({type: this.tabType, requestObj: JSON.stringify(this.requestObj)})
        .then(result => {
            console.log('# WS result #');
            var obj = JSON.parse(result);
            console.log('# success: ' + result);

            if(obj.response.item === null || obj.response.item === undefined){
                this.errorMessage = obj.response.outcomeSapDescr;
                this.error = true;
            } else {
                this.contractDataToView = obj.response.item;
                this.afterWsCall();
            }

            this.spinner = false;
            
        }).catch(error => {
            this.error = true;
            this.errorMessage = 'Errore nella chiamata WebService';
            this.spinner = false;
        });
    
    }

    afterWsCall(){
        if(this.tabType === 'consumptionList2g'){
            if(this.contractDataToView[0].details.item.length > 0) {
                this.detailsDataToView.push(this.contractDataToView[0].details.item[0]);
                this.showDetailTable = true;
            } else {
                this.showDetailTable = false;
            }
        } else {
            this.showDetailTable = false;
        }

        this.spinner = false;  
    }

    /*setMockData(){
        this.contractDataToView.push(
            {
                idBrim: 'BDF',
                contract: '3003108153',
                consDateStart: '2022-05-28',
                consDateEnd: '2022-05-28',
                pod: 'IT230426051150',
                scanningDate: '0000-00-00',
                scanningType: 'SS',
                bandDiscount: '00',
                specialDay: 'null',
                dailyCost: 'null',
                dailyKwh: '4800',
                dailyKwhNet: '0000',
                dailyLossCost: 'null',
                dailyLossKwh: 'null',
                dailyDiscountKwh: '4800',
                dailyLossDiscountKwh: '0490',
                details: {
                    item: [ {
                        hour: '01',
                        hourlyCost: null,
                        hourlyKwh: '0,200'
                    }]
                }
            });
            this.contractDataToView.push(
                {
                    idBrim: 'BDF2',
                    contract: '3003108153',
                    consDateStart: '2022-05-28',
                    consDateEnd: '2022-05-28',
                    pod: 'IT230426051150',
                    scanningDate: '0000-00-00',
                    scanningType: 'SS',
                    bandDiscount: '00',
                    specialDay: 'null',
                    dailyCost: 'null',
                    dailyKwh: '4800',
                    dailyKwhNet: '0000',
                    dailyLossCost: 'null',
                    dailyLossKwh: 'null',
                    dailyDiscountKwh: '4800',
                    dailyLossDiscountKwh: '0490',
                    details: {
                        item: [ {
                            hour: '02',
                            hourlyCost: null,
                            hourlyKwh: '0,200'
                        }]
                    }
                });
                this.contractDataToView.push(
                    {
                        idBrim: 'BDF3',
                        contract: '3003108153',
                        consDateStart: '2022-05-28',
                        consDateEnd: '2022-05-28',
                        pod: 'IT230426051150',
                        scanningDate: '0000-00-00',
                        scanningType: 'SS',
                        bandDiscount: '00',
                        specialDay: 'null',
                        dailyCost: 'null',
                        dailyKwh: '4800',
                        dailyKwhNet: '0000',
                        dailyLossCost: 'null',
                        dailyLossKwh: 'null',
                        dailyDiscountKwh: '4800',
                        dailyLossDiscountKwh: '0490',
                        details: {
                            item: []
                        }
                    });
                    this.afterWsCall();
    }*/

    handleRowAction(event) {
        console.log('# handleRowAction #');
        //console.log('# handleRowAction >>> ' + JSON.stringify(event.detail.row));
        this.detailsDataToView = event.detail.row.details.item;

        if(event.detail.row.details.item.length > 0) {
            this.showDetailTable = true;
        } else {
            this.showDetailTable = false;
        }
        
    }

    buttonHandler(event){
        try {
            console.log('>>> BUTTON TYPE > ' + event.currentTarget.name);
            console.log('>>> BUTTON PARAMETERS > ' + event.currentTarget.dataset.parameters);
            this.modalHeader = event.currentTarget.dataset.label;
            this.modalBody = 'bodyNotRequired';
            this.parameter = event.currentTarget.dataset.parameters;
            this.buttonName = event.currentTarget.name;
            this.openModal = true;
        } catch(e){
            console.error('>>> buttonHandler');
            console.error('# Name => ' + e.name );
            console.error('# Message => ' + e.message );
            console.error('# Stack => ' + e.stack );
        }
    }

    applyConfirm(event){
        if(event.detail.decision === 'conf'){
            console.log('## applyConfirm ' + JSON.stringify(event.detail));
            this.requestObj = event.detail.requestObject;
            this.backendCall();
            this.focusOnButton(event.detail.buttonName);
        }
        this.openModal = false;
    }

    onHandleSort(event){
        console.log('## sort event ## ');

        try {
            const { fieldName: sortedBy, sortDirection } = event.detail;

            const cloneData = [...this.contractData];
            cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
            this.contractDataToView = cloneData;

            this.sortDirection = sortDirection;
            this.sortedBy = sortedBy;

        } catch(e) {
            console.log(e);
        }
     
    }

    sortBy(field, reverse, primer) {
        const key = primer
            ? function(x) {
                  return primer(x[field]);
              }
            : function(x) {
                  return x[field];
              };

        return function(a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }

}