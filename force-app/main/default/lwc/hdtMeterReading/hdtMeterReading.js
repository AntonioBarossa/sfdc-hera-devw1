import { LightningElement, api, track } from 'lwc';
import getContractRecords from '@salesforce/apex/HDT_LC_MeterReadingController.getContractRecords';
import getConfigurationData from '@salesforce/apex/HDT_LC_MeterReadingController.getConfigurationData';
//import getMeterReadingRecords from '@salesforce/apexContinuation/HDT_LC_AccountStatementController.getMeterReadingRecords';

const contractColumns = [
    {
        label: '',
        type: 'button',
        initialWidth: 160,
        typeAttributes: {
                            label: 'Visualizza Letture',
                            title: 'Seleziona',
                            variant: 'border-filled',
                            alternativeText: 'Seleziona'
                        }
    }
];

export default class HdtMeterReading extends LightningElement {
    
    @api recordid;
    @track contractColumns;
    @track contractNumber;
    @track meterReadingColumns;
    hideCheckboxColumn = true;
    loadData = false;
    queryTerm = '';
    spinner = true;
    error = false;
    showDetailTable = false;
    errorMessage = '';
    contractData = [];
    contractDataToView = [];
    sortDirection = 'desc';
    sortedBy;
    showModality;

    connectedCallback() {
        this.configurationData();
        this.contractBackendCall();
    }

    configurationData(){
        getConfigurationData()
        .then(result => {

            if(result.success){
                //console.log('>>> ' + result.contractTable);
                var obj = JSON.parse(result.contractTable);
                this.contractColumns = contractColumns.concat(obj.data);
                //this.meterReadingColumns = JSON.parse(result.meterReadingTable);
                this.showModality = result.trbEnable;
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

    contractBackendCall(){
        getContractRecords({accountId: this.recordid})
        .then(result => {

            if(result.success){
                this.contractData = result.contractList;
                this.contractDataToView =  result.contractList;
                this.contractNumber = this.contractData[0].contractNumber;
                this.contractService = this.contractData[0].service;
                this.showDetailTable = true;
                this.spinner = false;
            } else {
                console.log('>>>> ERROR > getContractRecords');
                this.error = true;
                this.errorMessage = result.message;
                this.spinner = false;
            }

        }).catch(error => {
            console.log('>>>> ERROR - getContractRecords');
            console.log(error);
        });
    }

    handleRowAction(event) {
        console.log('# handleRowAction #');
        this.template.querySelector('c-hdt-meter-reading-detail-table').loadingData();
        
        //if(this.contractNumber != event.detail.row.contractNumber) {
        //    this.template.querySelector('c-hdt-meter-reading-detail-table').loadingData();
        //    this.contractNumber = event.detail.row.contractNumber;
        //}
    }

    handleSearch(event) {
        this.contractDataToView = [];

        if(event.target.value!=''){
            var filteredContract = this.contractData.filter(c => {
                if(c.contractNumber.includes(event.target.value) || c.servicePoint.includes(event.target.value)){
                    return true;
                } else {
                    return false;
                }
            });

            if(filteredContract.length > 0){
                this.contractDataToView = filteredContract;
            }
        } else {
            this.contractDataToView = this.contractData;
        }
    }

    dataload(event){
        this.spinner = event.detail.spinner;
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