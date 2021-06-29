import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updateSale from '@salesforce/apex/HDT_LC_GeneralInfo.updateSale';
import getCurrentUserName from '@salesforce/apex/HDT_LC_GeneralInfo.getCurrentUserName';
import getChannelAgency from '@salesforce/apex/HDT_LC_GeneralInfo.getChannelAgency';
import getAgents from '@salesforce/apex/HDT_LC_GeneralInfo.getAgents';
import handleAutomaticAgentAssign from '@salesforce/apex/HDT_LC_GeneralInfo.handleAutomaticAgentAssign';
import getSaleContactRole from '@salesforce/apex/HDT_LC_GeneralInfo.getSaleContactRole';
export default class HdtGeneralInfo extends LightningElement {
    @api saleRecord = {};
    @api campaignId;
    @api campaignCommissioningId;
    disabledInput = false;
    hiddenEdit = true;
    loading = false;
    dataToSubmit = {};
    currentStep = 1;
    currentLetter;
    nextStep = 2;
    @track originalData = [];
    searchInputValue = null;
    currentUserName = '';
    submitButtonStatus = true;
    showEmptyMessage = false;
    selectedFromCompleteList = {};
    saleContactRoles = '';
    @track isCampaignTableVisible = false;

    @track isCampaignTableCommissioningVisible = false;
    @track isOutbound = false;

    @track disabledSave = true;
    totalPages = 0;
    totalPages2 = 0;
    @track pages = [];
    @track pages2 = [];
    @track disabledAgency = true;
    currentPage = 0;
    currentPage2 = 0;
    @track tableData = [];
    hiddenFilterAgent = true;
    @track hiddenAgency = false;
    @track showpage1 = true;
    @track showpage2 = false;
    @track disabledBack = true;
    @track disabledNext = false;
    disabledSelezioneAgenzia = false;
    @track disabledNextAgency = false;
    completeListcolumnsAgent = [];
    @track tableDataAgent = [];
    @track completeListAgent;
    @track ChannelSelection ='';
    @track additionalData=[];
    @track agentListForFilter = [];




    completeListcolumns = [];
    get isCampaignVisible() {
        return this.isCampaignTableVisible || this.saleRecord.Campaign__c !== undefined;
    }
    get isCampaignCommissioningVisible(){
        return this.isCampaignTableCommissioningVisible || this.saleRecord.CommissioningCampaign__c !== undefined;
    }

    get isCampaignInputVisible() {
        return this.disabledInput || (this.campaignId !== '' && this.campaignId !== undefined);
    }

    get isCampaignInputVisibleCommissioning(){
        return this.disabledInput || (this.campaignCommissioningId !== '' && this.campaignCommissioningId !== undefined);
    }

    toggle(){
        this.disabledInput = !this.disabledInput;
        this.disabledNext = !this.disabledNext;
        this.hiddenEdit = !this.hiddenEdit;
        this.disabledSelezioneAgenzia = !this.disabledSelezioneAgenzia;
    }

    handleDataCollection(event) {
        this.dataToSubmit[event.target.fieldName] = event.target.value;

        if (event.target.fieldName === 'SalesContact__c') {
            this.saleContactRoles = '';
            getSaleContactRole({ accountId: this.saleRecord.Account__c, contactId: event.target.value }).then(data => {

                if (data[0].Roles !== undefined) {
                    this.saleContactRoles = data[0].Roles;
                    this.template.querySelector('[data-name="SalesContactRole__c"]').value = this.saleContactRoles;
                    this.dataToSubmit['SalesContactRole__c'] = this.saleContactRoles;
                } else {
                    this.saleContactRoles = '';
                    this.template.querySelector('[data-name="SalesContactRole__c"]').value = this.saleContactRoles;
                    this.dataToSubmit['SalesContactRole__c'] = this.saleContactRoles;
                }

            }).catch(error => {
                console.log(error.body.message);
                const toastErrorMessage = new ShowToastEvent({
                    title: 'Errore',
                    message: error.body.message,
                    variant: 'error',
                    mode: 'sticky'
                });
                this.dispatchEvent(toastErrorMessage);
            });
        }
        if (event.target.fieldName === 'Channel__c') {
            //this.template.querySelector("[data-id='Agency__c']").value = '';
            this.currentPage = 0;
            this.currentPage2 = 0; // reset page
            let Channel = this.template.querySelector('[data-name="Channel__c"]').value;
            this.ChannelSelection = event.target.value;
            if(Channel == null || Channel==''){
                this.disabledAgency = true;
            }else{
                this.disabledAgency = false;
            }
            
            if(Channel=='Back office'){
                this.createTable(this.originalData);

            }else{
                this.createTable([]);

            }

            if (Channel == 'Telefono' || Channel == 'Teleselling Inbound' || Channel == 'Teleselling Outbound') {
                //this.hiddenFilterAgent = true;
                this.hiddenAgency = true;
                handleAutomaticAgentAssign ({Channel:Channel,saleId:this.saleRecord.Id }).then(data =>{
                    console.log("************* "+JSON.stringify(data))
                    this.loaded = true;
                    this.template.querySelector("[data-id='Agency__c']").value = data[0].AgencyName__c;
                }).catch(error => {
                    this.loaded = true;
                    console.log(error.body.message);
                    const toastErrorMessage = new ShowToastEvent({
                        title: 'Errore',
                        message: error.body.message,
                        variant: 'error',
                        mode: 'sticky'
                    });
                    this.dispatchEvent(toastErrorMessage);
                });

            } else {
                this.hiddenAgency = false;
                this.template.querySelector("[data-id='Agency__c']").value = '';
                this.template.querySelector("[data-id='CommercialId']").value = '';

            }

        }
    }

    initDataToSubmit() {
        this.dataToSubmit['Id'] = this.saleRecord.Id;
        this.dataToSubmit['CurrentStep__c'] = this.nextStep;
    }

    handleEmitCampaignIdEvent(event) {
        this.dataToSubmit['Campaign__c'] = event.detail.campaignId;
    }

    handleEmitCampaignIdEvent2(event){
        this.dataToSubmit['CommissioningCampaign__c'] = event.detail.campaignId;
    }

    handleCampaignVisibility(event){

        this.isCampaignTableVisible = event.detail.isVisible;
    }
    handleCampaignVisibility2(event){
        this.isCampaignTableCommissioningVisible = event.detail.isVisible;
    }

    updateSaleRecord(saleData) {
        this.loading = true;
        updateSale({ sale: saleData }).then(data => {
            this.loading = false;
            this.dispatchEvent(new CustomEvent('saleupdate'));
        }).catch(error => {
            this.loading = false;
            console.log(error.body.message);
            const toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: error.body.message,
                variant: 'error'
            });
            this.dispatchEvent(toastErrorMessage);
        });
    }

    setUserName() {
        this.loading = true;
        getCurrentUserName().then(data => {
            this.loading = false;
            this.currentUserName = data;

        }).catch(error => {
            this.loading = false;
            console.log(error.body.message);
            const toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: error.body.message,
                variant: 'error'
            });
            this.dispatchEvent(toastErrorMessage);
        });
    }

    handleNext() {

        if (this.template.querySelector("[data-id='SalesContact__c']") !== null
            && (this.template.querySelector("[data-id='SalesContact__c']").value === ''
                || this.template.querySelector("[data-id='SalesContact__c']").value === null)) {
            this.loading = false;
            const toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: 'Popolare il campo Contatto Vendita',
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(toastErrorMessage);
            return;
        }

        if (this.template.querySelector("[data-id='Channel__c']") !== null
            && (this.template.querySelector("[data-id='Channel__c']").value === ''
                || this.template.querySelector("[data-id='Channel__c']").value === null)) {
            this.loading = false;
            const toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: 'Popolare il campo Canale',
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(toastErrorMessage);
            return;
        }

        this.updateSaleRecord(this.dataToSubmit);
        this.toggle();
        this.disabledAgency = true;
    }

    handleEdit() {
        this.updateSaleRecord({ Id: this.saleRecord.Id, CurrentStep__c: this.currentStep });
        this.toggle();
        this.disabledAgency = false;
    }

    connectedCallback() {
        console.log('hdtGeneralInfo - connectedCallback - campaignId: ', this.campaignId);

        //Set CreatedBy of Sale on component mount
        if (this.saleRecord.CreatedBy__c === '' || this.saleRecord.CreatedBy__c === null || this.saleRecord.CreatedBy__c === undefined) {
            this.setUserName();
        } else {
            this.currentUserName = this.saleRecord.CreatedBy__c;
        }

        this.initDataToSubmit();
        if (this.saleRecord.CurrentStep__c != this.currentStep) {
            this.toggle();
        }


    }



    @track openModal = false;
    handleAgencySelection() {

        this.openModal = true;
        this.disabledNextAgency = true;
        this.showEmptyMessage = false;
        let Channel = this.template.querySelector('[data-name="Channel__c"]').value;
        console.log("Channel", Channel)
       
            this.completeListcolumns = [
                { label: 'Nome Agenzia', fieldName: 'AgencyName__c', type: 'text' },
                { label: 'Codice Agenzia', fieldName: 'AgencyCode__c', type: 'text' },

            ];

        


        getChannelAgency({ Channel: this.ChannelSelection }).then(data => {

            this.completeList = [...data];

            console.log('completeListcompleteList: ', (this.completeList));
            this.originalData = this.completeList;

            if (this.completeList.length > 0) {
                console.log('handleAgencySelection: ', JSON.stringify(this.completeList));

                this.createTable(this.completeList);
            } else {
                this.showEmptyMessage = false;
                
            }


        }).catch(error => {
            console.log('Error: ', JSON.stringify(error));
            const toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: error.body.message,
                variant: 'error'
            });
            this.dispatchEvent(toastErrorMessage);
        });

    }

    //Pagination start
    createTable(data) {
        let i, j, temporary, chunk = 6;
        this.pages = [];
        for (i = 0, j = data.length; i < j; i += chunk) {
            temporary = data.slice(i, i + chunk);
            this.pages.push(temporary);
        }
        this.totalPages = this.pages.length;
        this.reLoadTable();
    }

    reLoadTable() {
        this.tableData = this.pages[this.currentPage];
        console.log('tableData='+JSON.stringify(this.tableData));

    }


    createTable2(data) {
        let i, j, temporary, chunk = 6;
        this.pages = [];
        for (i = 0, j = data.length; i < j; i += chunk) {
            temporary = data.slice(i, i + chunk);
            this.pages.push(temporary);
        }
        this.totalPages = this.pages.length;
        this.reLoadTable2();
    }

    reLoadTable2() {
        console.log('tableData='+JSON.stringify(this.tableDataAgent));
        this.tableDataAgent = this.pages[this.currentPage2];

    }

    get showPaginationButtons() {
        return this.totalPages > 1;
    }

    get getCurrentPage() {
        if (this.totalPages === 0) {
            return 0;
        } else {
            return this.currentPage + 1;
        }
    }

    nextPage() {
        if (this.currentPage < this.totalPages - 1) {
            this.currentPage++;
        }
        this.reLoadTable();
    }
    
    previousPage() {
        if (this.currentPage > 0) {
            this.reLoadTable();
            this.currentPage--;
        }
        this.reLoadTable();
    }
    closeModal() {
        this.showpage1 = true;
        this.showpage2 = false;        
        this.openModal = false;
        this.disabledNextAgency = true;


    }

    /**
    * Filter Data-Table
    */
    searchAgencyName(event) {
        let val = event.target.value;
        let self = this;
        let data;
        setTimeout(function () {
            data = JSON.parse(JSON.stringify(self.originalData));
            if (val.trim() !== '') {
                data = data.filter(row => {
                    let found = false;
                    Object.values(row).forEach(v => {
                        if (v !== undefined && typeof(v)== "string" && null != v.toLowerCase() && (v.toLowerCase().search(val.toLowerCase()) !== -1)) {
                            found = true;
                        }
                    });
                    if (found) return row;
                })

            }
            self.createTable(data); // redesign table
            self.currentPage = 0; // reset page
        }, 1000);

    }
    handleSearchInputKeyChange(event) {
        this.searchInputValue = event.target.value;
        if (this.searchInputValue.length > 3) {
            this.submitButtonStatus = false;
        } else {
            this.submitButtonStatus = true;

        }
    }

    getSelectedFromCompleteList(event) {
        let selectedRows = event.detail.selectedRows;
        this.selectedFromCompleteList = (selectedRows[0] !== undefined) ? selectedRows[0] : {};
        this.disabledNextAgency = false;

        console.log('getSelectedFromCompleteList: ', this.selectedFromCompleteList);


    }

    getSelectedFromCompleteListAgent(event) {
        let selectedRows = event.detail.selectedRows;
        this.selectedFromCompleteListAgent = (selectedRows[0] !== undefined) ? selectedRows[0] : {};

        console.log('getSelectedFromCompleteListAgent: ', this.selectedFromCompleteListAgent);
        this.disabledSave = false;


    }

    handleSave() {
        this.showpage1 = true;
        this.showpage2 = false;

        if (Object.keys(this.selectedFromCompleteList).length != 0) {


            this.updateSaleRecord({ Id: this.saleRecord.Id, Agency__c: this.selectedFromCompleteList.AgencyName__c, AgencyCode__c: this.selectedFromCompleteList.AgencyCode__c,
            VendorLastName__c:this.selectedFromCompleteListAgent.AgentLastName__c, VendorFirstName__c:this.selectedFromCompleteListAgent.AgentFirstName__c,CommercialId__c:this.selectedFromCompleteListAgent.AgentCode__c,
            UpperChannelAgency__c:this.selectedFromCompleteListAgent.UpperChannelAgency__c, LowerChannelAgency__c:this.selectedFromCompleteListAgent.LowerChannelAgency__c,
            IsMonitoring__c:this.selectedFromCompleteListAgent.IsMonitoring__c});
            this.currentPage = 0;
            this.currentPage2 = 0; // reset page
            //this.toggle();
            this.openModal = false;
            //this.template.querySelector('[data-name="Agency__c"]').setAttribute('value', this.selectedFromCompleteList.AgencyName__c);
            this.template.querySelector("[data-id='Agency__c']").value = this.selectedFromCompleteList.AgencyName__c;
            this.template.querySelector("[data-id='CommercialId']").value = this.selectedFromCompleteListAgent.AgentCode__c;

        }

    }

    handleAdditionalFilter() {
        this.openModal = true;
        this.showEmptyMessage = false;
        let Channel = this.template.querySelector('[data-name="Channel__c"]').value;

        this.completeListcolumnsAgent = [
            { label: 'Nome Agente', fieldName: 'AgentFirstName__c', type: 'text' },
            { label: 'Cognome Agente', fieldName: 'AgentLastName__c', type: 'text' },
            { label: 'Codice Agente', fieldName: 'AgentCode__c', type: 'text' },

        ];

        console.log("Channel", Channel);
        console.log("this.selectedFromCompleteList.AgencyName__c", this.selectedFromCompleteList.AgencyName__c);


        getAgents({AgencyName:this.selectedFromCompleteList.AgencyName__c, Channel:Channel}).then(data => {
            

            this.completeListAgent = [...data];

            console.log('getAgents completeListcompleteList: ', (this.completeListAgent));
            //this.additionalData = this.completeListAgent;

            this.completeListAgent.forEach(item => {
                this.agentListForFilter.push({
                    AgentFirstName__c : item.AgentFirstName__c,
                    AgentLastName__c : item.AgentLastName__c,
                    AgentCode__c : item.AgentCode__c
                });

            });

            if (this.completeListAgent.length > 0) {
                console.log('getAgents: ', JSON.stringify(this.completeListAgent));

                this.currentPage2 = 0;
                this.createTable2(this.completeListAgent);
                this.disabledNextAgency =true;
            } else {
                this.showEmptyMessage = false;
            }


        }).catch(error => {
            console.log('Error: ', JSON.stringify(error));
            const toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: error.body.message,
                variant: 'error'
            });
            this.dispatchEvent(toastErrorMessage);
        });


    }

    renderedCallback() {
        let Channel = this.template.querySelector('[data-name="Channel__c"]').value;

        if (this.saleRecord.Agency__c != null && Channel != 'Telefono' && Channel != 'Teleselling Inbound' && Channel != 'Teleselling Outbound') {
            //this.hiddenFilterAgent = false;
            this.hiddenAgency = false;
        }
    }

    handleBackPage(event) {


        this.showpage1 = true;
        this.showpage2 = false;
        this.handleAgencySelection();
        this.disabledNextAgency = false;
        this.disabledBack = true;
        this.disabledSave = true;

    }

    handleNextPage(event) {


        this.showpage1 = false;
        this.showpage2 = true;
        this.handleAdditionalFilter();
        this.disabledNextAgency = true;
        this.disabledBack = false;
        


    }

    
    searchAgentTable(event) {
        let val = event.target.value;
        let self = this;
        let data;
        setTimeout(function () {
            data = JSON.parse(JSON.stringify(self.completeListAgent));
            if (val.trim() !== '') {
                data = data.filter(row => {
                    let found = false;
                    Object.values(row).forEach(v => {
                        if (v !== undefined && typeof(v)== "string" && null != v.toLowerCase() && (v.toLowerCase().search(val.toLowerCase()) !== -1)) {
                            found = true;
                        }
                    });
                    if (found) return row;
                })

            }
            self.createTable2(data); // redesign table
            self.currentPage2 = 0; // reset page
        }, 1000);

    }

    handleSearchAgentTableInput(event) {
        this.searchInputValue = event.target.value;
        if (this.searchInputValue.length > 3) {
            this.submitButtonStatus = false;
        } else {
            this.submitButtonStatus = true;

        }
    }

    get showPaginationButtons2() {
        return this.totalPages2 > 1;
    }

    get getCurrentPage2() {
        if (this.totalPages2 === 0) {
            return 0;
        } else {
            return this.currentPage2 + 1;
        }
    }

    nextPage2() {
        if (this.currentPage2 < this.totalPages2 - 1) {
            this.currentPage2++;
        }
        this.reLoadTable2();
    }

    previousPage2() {
        if (this.currentPage2 > 0) {
            this.currentPage2--;
        }
        this.reLoadTable2();
    }

}



