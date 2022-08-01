import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updateSale from '@salesforce/apex/HDT_LC_GeneralInfo.updateSale';
import getCurrentUserName from '@salesforce/apex/HDT_LC_GeneralInfo.getCurrentUserName';
import getChannelAgency from '@salesforce/apex/HDT_LC_GeneralInfo.getChannelAgency';
import getAgents from '@salesforce/apex/HDT_LC_GeneralInfo.getAgents';
import handleAutomaticAgentAssign from '@salesforce/apex/HDT_LC_GeneralInfo.handleAutomaticAgentAssign';
import getSaleContactRole from '@salesforce/apex/HDT_LC_GeneralInfo.getSaleContactRole';
import initComp from '@salesforce/apex/HDT_LC_GeneralInfo.initComp';
import { ingestDataConnector } from 'lightning/analyticsWaveApi';
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
    @track isServiceCommissioning = false;
    @api categoriacampagna = 'Campagna Outbound';
    @api canalecampagna ='Telefonico Outbound';
    @track isCampaignTableCommissioningVisible = false;
    @api isoutbound = false;

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
    userRole = '';
    @track channelDisabled = false;
    @track channelValue = '';
    isProfileTeleselling = false;
    @track filterLookup = '';

    @track valueObj = '';

    channelOptionsComm = [
        {label: 'Teleselling Inbound', value: 'Teleselling Inbound'},
        {label: 'Teleselling Outbound', value: 'Teleselling Outbound'}
    ];

    completeListcolumns = [];
    get isCampaignVisible() {
        return (this.isCampaignTableVisible && !this.disabledInput)  || (this.saleRecord.Campaign__c !== undefined && this.disabledInput);
    }
    
    get isCampaignCommissioningVisible(){
        return !this.disabledInput || (this.saleRecord.CommissioningCampaign__c !== undefined && this.disabledInput);
    }

    get isCampaignInputVisible() {
        return this.disabledInput || (this.campaignId !== '' && this.campaignId !== undefined);
    }

    get isCampaignInputVisibleCommissioning(){
        return this.disabledInput || (this.campaignCommissioningId !== '' && this.campaignCommissioningId !== undefined);
    }

    get isCommissioningVisiEnter(){
        return this.isoutbound || this.isServiceCommissioning;
    }

    toggle(){
        this.channelDisabled = !this.channelDisabled;
        this.disabledInput = !this.disabledInput;
        this.disabledNext = !this.disabledNext;
        this.hiddenEdit = !this.hiddenEdit;
        this.disabledSelezioneAgenzia = !this.disabledSelezioneAgenzia;
    }


    handleContactSelection(event)
    {
        console.log('# OnSelectEvent >>> ' + JSON.stringify(event.detail));
        this.dataToSubmit['SalesContact__c'] = event.detail.code;
        this.valueObj = event.detail.name;
        getSaleContactRole({accountId: this.saleRecord.Account__c, contactId: this.dataToSubmit['SalesContact__c']})
        .then(data => 
            {
                this.dataToSubmit['SalesContactRole__c'] = data[0].Roles;
                console.log('# Data To Submit >>> ' + JSON.stringify(this.dataToSubmit));
            })
    }

    handleDataCollection(event) {
        this.dataToSubmit[event.target.fieldName] = event.target.value;

        if (event.target.fieldName === 'Channel__c') {

            this.template.querySelector("[data-id='Agency__c']").value = '';
            this.template.querySelector("[data-id='CommercialId']").value = '';
            this.template.querySelector("[data-id='VendorFirstName__c']").value = '';
            this.template.querySelector("[data-id='VendorLastName__c']").value = '';
            
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
            if(Channel == 'Teleselling Inbound' || Channel == 'Teleselling Outbound'){
                this.isServiceCommissioning = true;
            }
            else{
                this.isServiceCommissioning = false;
            }
            if (this.userRole !== 'HDT_BackOffice' && (Channel == 'Telefono' || Channel == 'Teleselling Inbound' || Channel == 'Teleselling Outbound' || Channel == 'Sportello' )) {
                this.hiddenAgency = true;
                handleAutomaticAgentAssign ({Channel:Channel,saleId:this.saleRecord.Id }).then(data =>{
                    console.log("************* "+JSON.stringify(data))
                    this.loaded = true;
                    this.template.querySelector("[data-id='Agency__c']").value = data[0].AgencyName__c;
                    this.template.querySelector("[data-id='CommercialId']").value = data[0].AgentCode__c;
                    this.template.querySelector("[data-id='VendorFirstName__c']").value = data[0].AgentFirstName__c;
                    this.template.querySelector("[data-id='VendorLastName__c']").value = data[0].AgentLastName__c;
                }).catch(error => {
                    this.loaded = true;
                    this.disabledAgency = false;
                    console.log(error.body.message);
                    const toastErrorMessage = new ShowToastEvent({
                        title: 'Errore',
                        message: error.body.message,
                        variant: 'warning',
                        mode: 'sticky'
                    });
                    //this.dispatchEvent(toastErrorMessage);
                });
            } else {
                this.hiddenAgency = false;
                this.template.querySelector("[data-id='Agency__c']").value = '';
                this.template.querySelector("[data-id='CommercialId']").value = '';
                this.template.querySelector("[data-id='VendorFirstName__c']").value = '';
                this.template.querySelector("[data-id='VendorLastName__c']").value = '';
            }

        }
    }

    initDataToSubmit() {
        this.dataToSubmit['Id'] = this.saleRecord.Id;
        this.dataToSubmit['CurrentStep__c'] = this.nextStep;
    }

    handleEmitCampaignIdEvent(event) {
        console.log('Try:******' + JSON.stringify(event));
        this.dataToSubmit['Campaign__c'] = event.detail.campaignId;
    }

    handleEmitCampaignIdEvent2(event){
        console.log('Try:******' + JSON.stringify(event.detail.campaignId));
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

    initCompAction() {
        this.loading = true;
        initComp().then(data => {
            this.loading = false;
            console.log('HDT_LC_GeneralInfo - initCompAction: ' + JSON.stringify(data));

            this.userRole = data.userRole;
            this.isProfileTeleselling = data.userProfile === 'Hera Teleseller Partner User';

        }).catch(error => {
            this.loading = false;

            let errorMessage = '';

            if (error.body.message !== undefined) {
                errorMessage = error.body.message;
            } else if(error.message !== undefined){
                errorMessage = error.message;
            } else if(error.body.pageErrors !== undefined){
                errorMessage = error.body.pageErrors[0].message;
            }

            console.log('Error: ', errorMessage);
            const toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: errorMessage,
                variant: 'error',
                mode: 'sticky'
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

        /*if (this.template.querySelector("[data-id='SalesContact__c']") !== null
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
        }*/
        
        /* Controllo sales contact */
        console.log('# SalesContact >>>' + this.dataToSubmit['SalesContact__c']);
        if(this.dataToSubmit['SalesContact__c'] == null || this.dataToSubmit['SalesContact__c'] == undefined || this.dataToSubmit['SalesContact__c'] == '')
        {
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

        if (this.template.querySelector("[data-id='Agency__c']") !== null
            && (this.template.querySelector("[data-id='Agency__c']").value === ''
                || this.template.querySelector("[data-id='Agency__c']").value === null)) {
            this.loading = false;
            const toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: 'Popolare il campo Agenzia',
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(toastErrorMessage);
            return;
        }

        if (this.template.querySelector("[data-id='CommercialId']") !== null
            && (this.template.querySelector("[data-id='CommercialId']").value === ''
                || this.template.querySelector("[data-id='CommercialId']").value === null)) {
            this.loading = false;
            const toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: 'Popolare il campo Venduto Da',
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
        this.dataToSubmit['Channel__c'] = this.template.querySelector('[data-id="Channel__c"]').value;
        console.log('*******1: ' + JSON.stringify(this.dataToSubmit) );
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

        console.log('Channel:::::::' + this.saleRecord.Channel__c);
        this.channelValue = this.saleRecord.Channel__c;
        this.filterLookup = 'AccountId = \'' + this.saleRecord.Account__c + '\'';
        if(this.saleRecord.SalesContact__c !== null && this.saleRecord.SalesContact__c !== undefined && this.saleRecord.SalesContact__c !== '')
        {
            this.valueObj = this.saleRecord.SalesContact__r.Name;
        }
       if(this.saleRecord.Channel__c == 'Teleselling Inbound' || this.saleRecord.Channel__c == 'Teleselling Outbound'){
            this.isServiceCommissioning = true;
            console.log('Channel:::::::true');
        }
        else{
            this.isServiceCommissioning = false;
        }
        console.log('hdtGeneralInfo - connectedCallback - campaignId: ', this.campaignId);

        this.initCompAction();

        if (this.saleRecord.CreatedBy__c === '' || this.saleRecord.CreatedBy__c === null || this.saleRecord.CreatedBy__c === undefined) {
            this.setUserName();
        } else {
            this.currentUserName = this.saleRecord.CreatedBy__c;
        }

        this.initDataToSubmit();
        console.log('# SaleRecord.Step >>> ' + this.saleRecord.CurrentStep__c);
        console.log('# Variable step >>> ' +this.currentStep);
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
    }

    createTable2(data) {
        let i, j, temporary, chunk = 6;
        this.pages2 = [];
        for (i = 0, j = data.length; i < j; i += chunk) {
            temporary = data.slice(i, i + chunk);
            this.pages2.push(temporary);
        }
        this.totalPages2 = this.pages2.length;
        this.reLoadTable2();
    }

    reLoadTable2() {
        console.log('tableData='+JSON.stringify(this.tableDataAgent));
        this.tableDataAgent = this.pages2[this.currentPage2];
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
                    let rowValues=[];
                    Object.entries(row).forEach(([key, value]) => {
                        if(key != 'Id'){
                            rowValues.push(value);
                        }
                    });
                    rowValues.forEach(v => {
                        if (v !== undefined && typeof(v)== "string" && v!='Id' && null != v.toLowerCase() && (v.toLowerCase().search(val.toLowerCase()) !== -1)) {
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

        console.log('getSelectedFromCompleteListAgent: '+ JSON.stringify(this.selectedFromCompleteListAgent));
        this.disabledSave = false;
    }

    handleSave() {
        this.showpage1 = true;
        this.showpage2 = false;

        if (Object.keys(this.selectedFromCompleteList).length != 0) {

            let saleUpdateAgent = { 
                Id: this.saleRecord.Id,
                Agency__c: this.selectedFromCompleteList.AgencyName__c,
                AgencyCode__c: this.selectedFromCompleteList.AgencyCode__c,
                VendorLastName__c:this.selectedFromCompleteListAgent.AgentLastName__c,
                VendorFirstName__c:this.selectedFromCompleteListAgent.AgentFirstName__c,
                CommercialId__c:this.selectedFromCompleteListAgent.AgentCode__c,
                UpperChannelAgency__c:this.selectedFromCompleteListAgent.UpperChannelAgency__c,
                LowerChannelAgency__c:this.selectedFromCompleteListAgent.LowerChannelAgency__c,
                IsMonitoring__c:this.selectedFromCompleteListAgent.IsMonitoring__c,
                AreaManager__c: this.selectedFromCompleteListAgent.AreaManager__c
            };

            this.updateSaleRecord(saleUpdateAgent);
            this.currentPage = 0;
            this.currentPage2 = 0; // reset page
            this.openModal = false;
            this.template.querySelector("[data-id='Agency__c']").value = this.selectedFromCompleteList.AgencyName__c;
            this.template.querySelector("[data-id='CommercialId']").value = this.selectedFromCompleteListAgent.AgentCode__c;
            this.template.querySelector("[data-id='VendorFirstName__c']").value = this.selectedFromCompleteListAgent.AgentFirstName__c;
            this.template.querySelector("[data-id='VendorLastName__c']").value = this.selectedFromCompleteListAgent.AgentLastName__c;

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
            { label: 'Area Manager', fieldName: 'AreaManager__c', type: 'text' },
        ];

        console.log("Channel", Channel);
        console.log("this.selectedFromCompleteList.AgencyName__c", this.selectedFromCompleteList.AgencyName__c);

        getAgents({AgencyName:this.selectedFromCompleteList.AgencyName__c, Channel:Channel}).then(data => {

            this.completeListAgent = [...data];

            console.log('getAgents completeListcompleteList: ', (this.completeListAgent));

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
        let channelCheck = '';
        if (this.saleRecord.CreatedBy.LoginChannel__c == 'Sportello') {
            this.channelValue = 'Sportello';
            channelCheck = 'Sportello';
            this.ChannelSelection = 'Sportello';
            this.channelDisabled = true;
            handleAutomaticAgentAssign ({Channel:'Sportello',saleId:this.saleRecord.Id }).then(data =>{
                console.log("************* "+JSON.stringify(data))
                this.loaded = true;
                this.template.querySelector("[data-id='Agency__c']").value = data[0].AgencyName__c;
                this.template.querySelector("[data-id='CommercialId']").value = data[0].AgentCode__c;
                this.template.querySelector("[data-id='VendorFirstName__c']").value = data[0].AgentFirstName__c;
                this.template.querySelector("[data-id='VendorLastName__c']").value = data[0].AgentLastName__c;
                if(data.length>1){
                    this.disabledAgency = false;
                }
            }).catch(error => {
                this.loaded = true;
                this.disabledAgency = false;
                console.log(error.body.message);
                const toastErrorMessage = new ShowToastEvent({
                    title: 'Errore',
                    message: error.body.message,
                    variant: 'warning',
                    mode: 'sticky'
                });
                //this.dispatchEvent(toastErrorMessage);
            });
        }
        else if (this.saleRecord.CreatedBy.LoginChannel__c == 'Telefono Outbound') {
            this.channelValue = 'Telefono';
            this.ChannelSelection = 'Telefono';
            channelCheck = 'Telefono';
            this.channelDisabled = true;
            handleAutomaticAgentAssign ({Channel:'Telefono',saleId:this.saleRecord.Id }).then(data =>{
                console.log("************* "+JSON.stringify(data))
                this.loaded = true;
                this.template.querySelector("[data-id='Agency__c']").value = data[0].AgencyName__c;
                this.template.querySelector("[data-id='CommercialId']").value = data[0].AgentCode__c;
                this.template.querySelector("[data-id='VendorFirstName__c']").value = data[0].AgentFirstName__c;
                this.template.querySelector("[data-id='VendorLastName__c']").value = data[0].AgentLastName__c;
                if(data.length>1){
                    this.disabledAgency = false;
                }
            }).catch(error => {
                this.loaded = true;
                this.disabledAgency = false;
                console.log(error.body.message);
                const toastErrorMessage = new ShowToastEvent({
                    title: 'Errore',
                    message: error.body.message,
                    variant: 'warning',
                    mode: 'sticky'
                });
                //this.dispatchEvent(toastErrorMessage);
            });
        }
        else if (this.saleRecord.CreatedBy.LoginChannel__c == 'Telefono Inbound') {
            this.channelValue = 'Telefono';
            this.ChannelSelection = 'Telefono';
            channelCheck = 'Telefono';
            this.channelDisabled = true;
            handleAutomaticAgentAssign ({Channel:'Telefono',saleId:this.saleRecord.Id }).then(data =>{
                console.log("************* "+JSON.stringify(data))
                this.loaded = true;
                this.template.querySelector("[data-id='Agency__c']").value = data[0].AgencyName__c;
                this.template.querySelector("[data-id='CommercialId']").value = data[0].AgentCode__c;
                this.template.querySelector("[data-id='VendorFirstName__c']").value = data[0].AgentFirstName__c;
                this.template.querySelector("[data-id='VendorLastName__c']").value = data[0].AgentLastName__c;
                if(data.length>1){
                    this.disabledAgency = false;
                }
            }).catch(error => {
                this.loaded = true;
                this.disabledAgency = false;
                console.log(error.body.message);
                const toastErrorMessage = new ShowToastEvent({
                    title: 'Errore',
                    message: error.body.message,
                    variant: 'warning',
                    mode: 'sticky'
                });
                //this.dispatchEvent(toastErrorMessage);
            });
        }

        if (this.saleRecord.Agency__c != null && Channel != 'Telefono' && Channel != 'Teleselling Inbound' && Channel != 'Teleselling Outbound') {
            this.hiddenAgency = false;
        }

        this.dataToSubmit['Channel__c']  = channelCheck;
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
        this.showPaginationButtons2 = true;
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
    get tabClass(){
        return this.disabledInput ? this.isCampaignInputVisible ?  'class1'  : 'slds-hidden' : '';
    }
    get tabClass2(){
        return this.disabledInput ? (this.isCampaignInputVisibleCommissioning ?  'class1'  : 'slds-hidden' ) : '';
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

    handleChannelComm(event){
        this.dataToSubmit['Channel'] = event.target.value;
        this.disabledAgency = false;

        this.hiddenAgency = true;
        handleAutomaticAgentAssign ({Channel:event.target.value,saleId:this.saleRecord.Id }).then(data =>{
            console.log("************* "+JSON.stringify(data))
            this.loaded = true;
            this.template.querySelector("[data-id='Agency__c']").value = data[0].AgencyName__c;
            this.template.querySelector("[data-id='CommercialId']").value = data[0].AgentCode__c;
            this.template.querySelector("[data-id='VendorFirstName__c']").value = data[0].AgentFirstName__c;
            this.template.querySelector("[data-id='VendorLastName__c']").value = data[0].AgentLastName__c;
        }).catch(error => {
            this.loaded = true;
            this.disabledAgency = false;
            console.log(error.body.message);
            const toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: error.body.message,
                variant: 'warning',
                mode: 'sticky'
            });
            //this.dispatchEvent(toastErrorMessage);
        });
    }
}