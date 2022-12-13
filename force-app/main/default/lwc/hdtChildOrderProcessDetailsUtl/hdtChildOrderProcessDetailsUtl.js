import { cities as tariNonResidenti } from './hdtTariNonResidenti.js';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import * as rateCategories from './hdtRateCategories.js';
    class fieldData{
        constructor(label, apiname, typeVisibility, required, disabled, processVisibility, value, func) {
            this.label = label;
            this.apiname=apiname;
            this.typeVisibility = typeVisibility;
            this.required=required;
            this.disabled=disabled;
            this.processVisibility=processVisibility;
            this.value=value;
            this.changeFunction=func;//You can define a function that recive and handle the change event
        }
        static dataInstanceDiffObj(label, apiname, typeVisibility, required, disabled, processVisibility, value){
            const data = new fieldData(label, apiname, typeVisibility, required, disabled, processVisibility, value);
            data.diffObjApi=true;
            data.isMockPicklist=false;
            return data;
        }
        static justLabelAndVisibilityEx(label,typeVisibility){
            return new MyClass(label,null,typeVisibility);
        }
        
    }

    class wrp2Infos{
        constructor(val1, val2){
            this.val1=val1;
            this.val2=val2;
        }
    }

    function getFormattedDate(date){
        let month = date.getMonth()+1;
        month = month<10? "0"+month : month;
        let day = date.getDate()<10? "0"+date.getDate() : date.getDate();
        return date.getFullYear()+'-'+month+'-'+day;
    }

    function equalsIgnoreCase(str1, str2){
        return typeof str1 === 'string' && typeof str2 === 'string'? 
                    str1.localeCompare(str2, undefined, { sensitivity: 'accent' }) === 0
                    : str1 === str2;
    }

    function safeStr(str){
        if(str) return `${str}`;
        return "";
    }

    function checkHousingUnitRateCategory( housingUnit, rateCateg ){
        if( housingUnit > 1 && (rateCateg === 'ACDOMRESP0' || rateCateg === 'ACDOMNR000' || rateCateg === 'ACARTCOMM0') )
        {
            try{
                dispatchEvent(new ShowToastEvent({
                    title: 'Warning',
                    message: 'Procedendo con la Rate Category selezionata e più unità totali si perderà l\'informazione delle unità immobiliari realmente servite dal contatore',
                    variant: 'warning'
                    })
                );
            } catch(e) {
                console.log(e)
            }
        }
        return;
    }

    function checkSectionRequiredFields(sectionName){
        const reg = new RegExp('^\\*?(.+)\\n?');
        const valuation = [
                ...this.template.querySelectorAll(`lightning-accordion-section[data-section-name='${sectionName}'] lightning-input-field`)
            ].reduce(
                (Fields, elem) => {
                        if(elem.required && !(elem.disabled || elem.value)){
                            let fname = elem.outerText?.match(reg)?.[1];
                            Fields.labels+=`, ${fname}`;
                            Fields.apinames.push(elem.fieldName);
                        }
                        return Fields;
                    }, {labels : "", apinames : []}
                );
        console.log("missing fields "+valuation.apinames);
        const message = valuation.labels.slice(2);
        if(message){
            this.showMessage('Errore', 'Popolare i campi obbligatori: '+message, 'error');
            return true;
        }
    }

    function savePredefaultedFields(sectionName){
        this.template
        .querySelectorAll(
            `lightning-accordion-section[data-section-name='${sectionName}'] `+
            "lightning-input-field[data-value='true']"
        ).forEach(el=>{
            this.sectionDataToSubmit[el.fieldName]=el.value;
        })
    }

    const handleSections = function() {
        this.fields = [
            {
                step: 1,
                label: 'Variabili di Processo',
                name: 'variabiliDiProcesso',
                objectApiName: 'Order',
                recordId: this.order.Id,
                hasCodiceRonchiButton: this.order.RateCategory__c=='TATND00001' && !["HDT_RT_AgevolazioniAmbiente", "HDT_RT_ModificaTariffaRimozione"].includes(this.order.RecordType.DeveloperName),
                //hasCodiceAtecoButton: this.order.RateCategory__c=='TATND00001' && !["HDT_RT_AgevolazioniAmbiente", "HDT_RT_ModificaTariffaRimozione"].includes(this.order.RecordType.DeveloperName),
                hasVerificaRavv: !["HDT_RT_AgevolazioniAmbiente"].includes(this.order.RecordType.DeveloperName),
                hasAllegatiObbligatori: true,
                diffObjApi: 'Sale',
                processVisibility: ["HDT_RT_SubentroAmbiente", "HDT_RT_AttivazioneAmbiente", "HDT_RT_CambioTariffa", 'HDT_RT_AgevolazioniAmbiente', 'HDT_RT_ModificaTariffaRimozione'].includes(this.order.RecordType.DeveloperName),
                nextActions : (evt, currentSectionIndex, nextSectionStep) => 
                    {
                        savePredefaultedFields.call(this, evt?.currentTarget?.value);
                        let decorrenza =this.template.querySelector("[data-id='EffectiveDate__c']")?.value;
                        let dichiarazione =this.template.querySelector("[data-id='DeclarationDate__c']")?.value;
                        const activeRepentant = this.template.querySelector("c-hdt-active-repentant");
                        //if(!this.isActiveRepentantPressed){
                        if(activeRepentant?.validateDate(decorrenza, dichiarazione)){
                            this.showMessage('Errore', 'Verificare il ravvedimento operoso prima di procedere', 'error');
                            return true;
                        }
        
                        if(!(this.closeAttachmentEvent?.buttonPressed && this.closeAttachmentEvent?.numberOfFiles)){
                            if(this.template.querySelector("[data-id='DeliveredDocumentation__c']")?.value == 'Y'){
                                this.showMessage('Errore', "Verificare gli allegati obbligatori per Documentazione da Contribuente", 'error');
                                //this.closeAttachmentEvent.isValid = true;
                                return true;
                            }else if(!this.closeAttachmentEvent?.buttonPressed){
                                this.showMessage('Errore', "Verificare gli allegati obbligatori prima di procedere", 'error');
                                return true;
                            }
                        }
                        const surface = this.template.querySelector("[data-id='Surface__c']");
                        if(this.order.RateCategory__c==='TATUDNR001' && this.order.RecordType.DeveloperName !== 'HDT_RT_AgevolazioniAmbiente' && surface?.value){
                            const fam = this.template.querySelector("[data-id='FamilyNumber__c']");
                            let value = tariNonResidenti[this.order.ServicePoint__r.SupplyCity__c?.toUpperCase()]?.getResident(surface.value);
                            if(value && fam)    fam.value = value;
                        }
                        //check mandatory section field section
                        if(checkSectionRequiredFields.call(this, evt?.currentTarget?.value)){   return true;}
                        /*You can do async operations before submitting
                            this function must return true, launch promise and when you're done, launch 
                            this.updateProcess(currentSectionIndex, nextSectionStep);
                        */
                        if(activeRepentant){
                            activeRepentant?.exportSieData(this.order)
                            .then(()=>{
                                this.updateProcess(currentSectionIndex, nextSectionStep);
                            })
                            .catch(error=>{
                                console.error(error);
                                this.showMessage('Errore', "Errore salvataggio ravvedimento operoso", 'error');
                            })
                            return true;
                        }
                    },
                data:[
                    //new fieldData('Codice Punto','ServicePointCode__c',this.typeVisibility('both'),true, true, '', ''),
                    //new fieldData('Servizio','CommodityFormula__c',this.typeVisibility('both'),true, false, '', ''),
                    new fieldData('Tipo Impianto','ImplantType__c', this.typeVisibility('both'), true, true,'',''),
                    new fieldData('Residente','Resident__c', this.typeVisibility('both'), false, true,'',''),
                    new fieldData('Codice ATECO','AtecoCode__c', !["HDT_RT_AgevolazioniAmbiente", "HDT_RT_ModificaTariffaRimozione"].includes(this.order.RecordType.DeveloperName), this.order.RateCategory__c=='TATND00001', false,'', this.order.Account.RecordType.DeveloperName === 'HDT_RT_Residenziale' ? '999999' : ''),
                    new fieldData('Codice Ronchi','RonchiCode__c', !["HDT_RT_AgevolazioniAmbiente", "HDT_RT_ModificaTariffaRimozione"].includes(this.order.RecordType.DeveloperName), this.order.RateCategory__c=='TATND00001', false,'',''),
                    new fieldData('Sottocategoria Ronchi','RonchiSubcat__c', !["HDT_RT_AgevolazioniAmbiente", "HDT_RT_ModificaTariffaRimozione"].includes(this.order.RecordType.DeveloperName), this.order.RateCategory__c=='TATND00001', false,'',''),
                    new fieldData('Contratto Precedente','ContractReference__c', ["HDT_RT_CambioTariffa", "HDT_RT_AgevolazioniAmbiente", "HDT_RT_ModificaTariffaRimozione", "HDT_RT_SubentroAmbiente"].includes(this.order.RecordType.DeveloperName), true, true,'',''),
                    new fieldData('Documentazione consegnata da contribuente','DeliveredDocumentation__c', this.typeVisibility('both'), false, false,'',''),
                    new fieldData('Provenienza richiesta','RequestSource__c', this.typeVisibility('both'), true, false,'','Da contribuente'),
                    new fieldData('Importo mancato dovuto','MissingDueAmount__c', !["HDT_RT_AgevolazioniAmbiente"].includes(this.order.RecordType.DeveloperName), false, true,'',''),
                    new fieldData('Pagamento Unico Annuale TARI','AnnualTARIPayment__c', !["HDT_RT_AgevolazioniAmbiente", "HDT_RT_ModificaTariffaRimozione"].includes(this.order.RecordType.DeveloperName), false, false,'','Disattiva'),
                    new fieldData('Data dichiarazione','DeclarationDate__c', !["HDT_RT_AgevolazioniAmbiente"].includes(this.order.RecordType.DeveloperName), true, false,'', getFormattedDate(new Date())),
                    new fieldData('Data decorrenza','EffectiveDate__c', !["HDT_RT_AgevolazioniAmbiente"].includes(this.order.RecordType.DeveloperName), true, false,'',''),
                    new fieldData('Integrazione alla Dichiarazione (da Gestore)','OperatorDeclarationInfos__c', this.typeVisibility('both'), false, false,'',''),
                    new fieldData('integrazione Riduzione Agevolazione Esclusione','IntegrationExclusion__c', true, false, !["HDT_RT_AgevolazioniAmbiente", "HDT_RT_ModificaTariffaRimozione"].includes(this.order.RecordType.DeveloperName),'',''),
                    new fieldData('Allegati obbligatori','MandatoryAttachments__c', this.typeVisibility('both'), false, true,'',''),
                    new fieldData('Allegati aggiuntivi','AdditionalAttachments__c', this.typeVisibility('both'), false, false,'','', function(){console.log("dynamic on change")}),
                    new fieldData('Blocca al calcolo','BlockOnComputation__c', this.order.Account.CompanyOwner__c!=="MMS", false, false,'',''),
                    new fieldData('Integrazione alla Dichiarazione (da Contribuente)','TaxpayerDeclarationInfos__c', this.typeVisibility('both'), false, false,'',''),
                    new fieldData('Inizio periodo ravvedibile','OnerousReviewableStartDate__c', !["HDT_RT_AgevolazioniAmbiente"].includes(this.order.RecordType.DeveloperName), false, true,'',''),
                    new fieldData('Inizio periodo non ravvedibile','OnerousUnreviewableStartDate__c', !["HDT_RT_AgevolazioniAmbiente"].includes(this.order.RecordType.DeveloperName), false, true,'',''),
                    new fieldData('Rifiuta supporto al calcolo del ravvedimento operoso','DeclineComputationSupport__c', this.order.Account.CompanyOwner__c!=="MMS", false, false,'',''),
                    new fieldData('Superficie Mq','Surface__c', ["HDT_RT_SubentroAmbiente", "HDT_RT_AttivazioneAmbiente"].includes(this.order.RecordType.DeveloperName), true, false,'', this.order.RecordType.DeveloperName=="HDT_RT_SubentroAmbiente"? this.order.ServicePoint__r.AreaDeclaredTARI__c : "")
                ]
            },
            {
                step: 2,
                label: 'Dati Sottoscrittore',
                name: 'datiSottoscrittore',
                objectApiName : 'Order',
                recordId: this.order.Id,
                diffObjApi: 'Account',
                diffRecordId: this.order.AccountId,
                processVisibility: ["HDT_RT_SubentroAmbiente", "HDT_RT_AttivazioneAmbiente", "HDT_RT_CambioTariffa", 'HDT_RT_AgevolazioniAmbiente', 'HDT_RT_ModificaTariffaRimozione'].includes(this.order.RecordType.DeveloperName),
                nextActions: (evt) => 
                    {
                        const famNumb =this.template.querySelector("[data-id='FamilyNumber__c']");
                        if(famNumb) this.sectionDataToSubmit["FamilyNumber__c"]=this.template.querySelector("[data-id='FamilyNumber__c']")?.value;
                        savePredefaultedFields.call(this, evt?.currentTarget?.value);
                        //check mandatory section field section
                        if(checkSectionRequiredFields.call(this, evt?.currentTarget?.value)){   return true;}
                    },
                data:[
                    new fieldData('Qualità','SubscriberType__c',this.typeVisibility('both'),true, false, '', '', 
                        function(event){
                            for(let wrp of [new wrp2Infos('CustomerName__c', "FirstName__c"), new wrp2Infos('CustomerLastName__c', "LastName__c"),new wrp2Infos('BirthPlace__c', "BirthProvince__c"),new wrp2Infos('BirthDate__c', "BirthDate__c")]){
                                let node = this.template.querySelector(`[data-id='${wrp.val1}']`);
                                if(!node)   return;
                                let value = equalsIgnoreCase(event.target.value, "Soggetto Passivo")? this.order.Account[wrp.val2] : "";
                                node.value=value;
                                this.sectionDataToSubmit[wrp.val1]=value;
                            }
                        }
                    ),
                    new fieldData('Comune di residenza','ResidentialCity__c',this.typeVisibility('both'),true, false, 'true', ''),
                    new fieldData('Indirizzo di residenza','ResidentialStreetName__c' , this.typeVisibility('both'), true, false, '',''),
                    new fieldData('Luogo di sottoscrizione','SubscriberPlace__c', this.typeVisibility('both'),true, false, 'true', this.order.Account.BillingPlace__c),
                    new fieldData('Nome','CustomerName__c', this.typeVisibility('both'), true, false,'',''),
                    new fieldData('Cognome','CustomerLastName__c', this.typeVisibility('both'), true, false,'',''),
                    new fieldData('Luogo di nascita','BirthPlace__c', this.typeVisibility('both'), true, false,'',''),
                    new fieldData('Data di nascita','BirthDate__c', this.typeVisibility('both'), true, false,'',''),
                    new fieldData('Nr Componenti Nucleso','FamilyNumber__c', this.order.RateCategory__c==='TATUDNR001' && this.order.RecordType.DeveloperName !== 'HDT_RT_AgevolazioniAmbiente', true, tariNonResidenti[this.order.ServicePoint__r.SupplyCity__c.toUpperCase()]?.readOnly,'', tariNonResidenti[this.order.ServicePoint__r.SupplyCity__c.toUpperCase()]?.getResident(this.order.Surface__c)?.toString()),
                    new fieldData('Nr Componenti Nucleso','FamilyNumber__c', this.order.RateCategory__c==='TATUDRES01' && this.order.RecordType.DeveloperName !== 'HDT_RT_AgevolazioniAmbiente', true, false,'', '')                    
                ]
            },
            {
                step: 3,
                label: 'Dati Catastali',
                name: 'datiCatastali',
                hasDatiCatastali: true,
                processVisibility: ["HDT_RT_SubentroAmbiente", "HDT_RT_AttivazioneAmbiente", "HDT_RT_CambioTariffa"].includes(this.order.RecordType.DeveloperName),
                nextActions : () => {
                    if(!this.landRedistrySelected){
                        this.showMessage('Errore', 'Salvare il dato catastale', 'error');
                        return true;
                    }   
                },
                data:[
                ]
            },
            {
                step: 4,
                label:'Fatturazione',
                name: 'fatturazione',
                objectApiName: 'Order',
                recordId: this.order.Id,
                processVisibility: ["HDT_RT_SubentroAmbiente", "HDT_RT_AttivazioneAmbiente", "HDT_RT_CambioTariffa", 'HDT_RT_AgevolazioniAmbiente', 'HDT_RT_ModificaTariffaRimozione'].includes(this.order.RecordType.DeveloperName),
                nextActions: (evt) => {
                    //check mandatory section field section
                    //if(checkSectionRequiredFields.call(this, evt?.currentTarget?.value)){   return true;}
                },
                data: [
                    new fieldData('Modalità Invio Bolletta', 'BillSendMode__c',this.typeVisibility('both'),false,true,'',''),
                    new fieldData('Email Invio Bolletta', 'InvoiceEmailAddress__c',this.typeVisibility('both'),false,true,'',''),
                    new fieldData('Email PEC invio Bolletta', 'InvoiceCertifiedEmailAddress__c',this.typeVisibility('both'),false,true,'',''),
                    new fieldData('SendCertifiedEmailConsentDate__c', 'SendCertifiedEmailConsentDate__c',this.typeVisibility('both'),false,true,'',''),
                    new fieldData('Destinatario Divergente', 'DivergentSubject__c',this.typeVisibility('both'),false,true,'',''),
                    new fieldData('Comune', 'BillingCity__c',this.typeVisibility('both'),false,true,'',''),
                    new fieldData('Stato', 'BillingCountry__c',this.typeVisibility('both'),false,true,'',''),
                    new fieldData('Localita', 'BillingPlace__c',this.typeVisibility('both'),false,true,'',''),
                    new fieldData('Provincia', 'BillingProvince__c',this.typeVisibility('both'),false,true,'',''),
                    new fieldData('Nome Via', 'BillingStreetName__c',this.typeVisibility('both'),false,true,'',''),
                    new fieldData('Civico', 'BillingStreetNumber__c',this.typeVisibility('both'),false,true,'',''),
                    new fieldData('CAP', 'BillingPostalCode__c',this.typeVisibility('both'),false,true,'',''),
                    new fieldData('Codice ISTAT', 'BillingCityCode__c',this.typeVisibility('both'),false,true,'',''),
                    //new fieldData('AggregateBilling__c', 'AggregateBilling__c',this.typeVisibility('both'),true,false,'',''),
                ]
            },
            {
                step: '',
                label: this.order.RecordType.DeveloperName === 'HDT_RT_Voltura' ? 'Riepilogo e Cliente Uscente' : 'Cliente Uscente',
                name: 'clienteUscente',
                objectApiName: 'Account',
                recordId: this.order.ServicePoint__c !== undefined ? this.order.ServicePoint__r.Account__c : '',
                diffObjApi: 'Order',
                diffRecordId: this.order.Id,
                processVisibility: this.order.ServicePoint__c !== undefined && this.order.ServicePoint__r.Account__c !== this.order.AccountId 
                    && (this.order.RecordType.DeveloperName === 'HDT_RT_Subentro' || this.order.RecordType.DeveloperName === 'HDT_RT_Voltura'
                    || (this.order.RecordType.DeveloperName === 'HDT_RT_VolturaConSwitch' && this.order.ServicePoint__r.CommoditySector__c.localeCompare('Energia Elettrica') === 0)),
                data: [
                    new fieldData('','Subprocess__c',this.order.RecordType.DeveloperName === 'HDT_RT_Voltura', false, true,'',''),
                    new fieldData('Nome','FirstName__c',this.order.Account.RecordType.DeveloperName === 'HDT_RT_Residenziale', false, true,'',''),
                    new fieldData('Cognome','LastName__c',this.order.Account.RecordType.DeveloperName === 'HDT_RT_Residenziale' , false, true,'',''),
                    new fieldData('Codice Fiscale','FiscalCode__c',true, false, true,'',''),
                    new fieldData('Partita IVA','VATNumber__c',true, false, true,'',''),
                    new fieldData('Ragione Sociale','Name',this.order.Account.RecordType.DeveloperName === 'HDT_RT_Business', false, true,'','')
                ]
            },
            {
                step: 3,
                label: 'Switch out in corso',
                name: 'Switchout',
                objectApiName: 'Order',
                recordId: this.order.Id,
                processVisibility: (this.order.RecordType.DeveloperName === 'HDT_RT_SwitchIn') && (this.order.SwitchOutDate__c != null),
                data: [
                    new fieldData('Data Cessazione Switchout','SwitchOutDate__c', this.typeVisibility('both'), false, true, '','')
                ]
            },
            {
                step: 3,
                label: 'Variabili di Processo',
                name: 'processVariables',
                objectApiName: 'Order',
                recordId: this.order.Id,
                readingButton:true,
                processVisibility: this.order.RecordType.DeveloperName === 'HDT_RT_Voltura' 
                || (this.order.RecordType.DeveloperName === 'HDT_RT_VolturaConSwitch'),
                data:[
                    new fieldData('Tipo Voltura','VoltureType__c',this.typeVisibility('both'),true,false,'',''),
                    new fieldData('','Subprocess__c',this.typeVisibility('both'),false,false,'',''),
                    new fieldData('','EffectiveDate__c',this.typeVisibility('both'),true,false,'',''),
                    new fieldData('','SignedDate__c',this.order.ParentOrder__r.SignedDate__c != null,true,true,'',this.order.ParentOrder__r.SignedDate__c),
                    new fieldData('','RetroactiveDate__c',this.typeVisibility('acqua') && this.order.Volture__c === 'Retroattiva' ,true,true,'',''),
                    new fieldData('','SendRequestDate__c', this.typeVisibility('acqua'), false, false, '',''),
                    new fieldData('','NotRegisteredMeterCase__c',this.order.RecordType.DeveloperName === 'HDT_RT_Voltura',false,false,'',''),
                    new fieldData('','MaxRequiredPotential__c',this.typeVisibility('gas'),this.order.RecordType.DeveloperName === 'HDT_RT_Voltura',false,'',''),
                    new fieldData('','FuiAccess__c', this.typeVisibility('gas'), false, false,'',''),
                    new fieldData('','AccountId',this.typeVisibility('both'),false,true,'',''),
                    new fieldData('','PhoneNumber__c',this.typeVisibility('both'),false,true,'',''),
                    new fieldData('','Email__c',this.typeVisibility('both'),false,true,'',''),
                    new fieldData('','PayPurification__c',this.typeVisibility('both'),false,false,'',''),
                    new fieldData('','PaySewer__c',this.typeVisibility('both'),false,false,'',''),
                    new fieldData('','SupplyAddressFormula__c',this.typeVisibility('acqua'),false,true,'',''),
                    new fieldData('','SupplyCity__c',this.typeVisibility('acqua'),false,true,'',''),
                    new fieldData('Tariffa','RateCategory__c', this.typeVisibility('acqua'), false, true, '',''),
                    new fieldData('','CohabitantsNumber__c', this.typeVisibility('acqua') && this.order.RecordType.DeveloperName === 'HDT_RT_Voltura', false, false, '',''),
                    new fieldData('Unita Immobiliari','RealEstateUnit__c', this.typeVisibility('acqua') && this.order.RecordType.DeveloperName === 'HDT_RT_Voltura', false, false, '','',
                        function(event){
                            checkHousingUnitRateCategory(event.target.value, this.order.RateCategory__c );
                        }
                    ),
                    //new fieldData('','Email__c',this.typeVisibility('both'),false,true,'',''),
                    new fieldData('Addebito Spese Contrattuali','ContractExpenses__c', this.typeVisibility('acqua') && this.rateCategoryVisibility(rateCategories.AQCNSANNOF), false, false, '',''),
                    new fieldData('','NotDisconnectabilityCustomer__c', this.typeVisibility('both') && this.rateCategoryVisibility(rateCategories.AF_NODISAL), false, false, '',''),
                    new fieldData('','SeasonUse__c', this.typeVisibility('both') && this.rateCategoryVisibility(rateCategories.ZGEWKEY), this.rateCategoryVisibility(rateCategories.ZGEWKEYreq), false, '',''),
                    new fieldData('','ForfaitSewer__c', this.typeVisibility('both') && this.rateCategoryVisibility(rateCategories.AQVOL_FORF), false, false, '',''),
                    new fieldData('','HydrantMouthsNumber__c', this.typeVisibility('both') && this.rateCategoryVisibility(rateCategories.AF_BOC_IDR), this.rateCategoryVisibility(rateCategories.AF_BOC_IDRreq), false, '',''),
                    new fieldData('','NumerousComunity__c', this.typeVisibility('both') && this.rateCategoryVisibility(rateCategories.AFNUM_COMP), false, true, '',''),
                    new fieldData('','DomesticResidentNumber__c', this.typeVisibility('both') && this.rateCategoryVisibility(rateCategories.AFNCOMP), this.rateCategoryVisibility(rateCategories.AFNCOMPreq), false, '',''),
                    new fieldData('','NotResidentDomesticHousingUnit__c', this.typeVisibility('both') && this.rateCategoryVisibility(rateCategories.AFUADNR), this.rateCategoryVisibility(rateCategories.AFUADNRreq), false, '',''),
                    new fieldData('','ResidentDomesticHousingUnit__c', this.typeVisibility('both') && this.rateCategoryVisibility(rateCategories.AFUADRS), false, true, '','1'),
                    new fieldData('','NotDomesticHousingUnit__c', 
                        this.typeVisibility('both') && ( this.rateCategoryVisibility(rateCategories.AFUND) || this.rateCategoryVisibility(rateCategories.AFUNDA) || this.rateCategoryVisibility(rateCategories.AFUNDC) || this.rateCategoryVisibility(rateCategories.AFUNDI) || this.rateCategoryVisibility(rateCategories.AFUNDZ) ), 
                        ( this.rateCategoryVisibility(rateCategories.AFUND) && this.rateCategoryVisibility(rateCategories.AFUNDreq) ) ||
                        ( this.rateCategoryVisibility(rateCategories.AFUNDA) && this.rateCategoryVisibility(rateCategories.AFUNDAreq) ) ||
                        ( this.rateCategoryVisibility(rateCategories.AFUNDC) && this.rateCategoryVisibility(rateCategories.AFUNDCreq) ) ||
                        ( this.rateCategoryVisibility(rateCategories.AFUNDI) && this.rateCategoryVisibility(rateCategories.AFUNDIreq) ) ||
                        ( this.rateCategoryVisibility(rateCategories.AFUNDZ) && this.rateCategoryVisibility(rateCategories.AFUNDZreq) ) , false, '',''),
                    new fieldData('','ZootechnicalHousingUnit__c', this.typeVisibility('acqua') && this.rateCategoryVisibility(rateCategories.AFUNDZ), false, false, '',''),
                    new fieldData('Consumi Anno','AnnualConsumption__c', this.typeVisibility('both') /* && this.rateCategoryVisibility(rateCategories.AQCNSANNOF) */, false, true, '',''),
                    new fieldData('','WithdrawalClass__c',this.typeVisibility('both'),false,true,'',''),
                    new fieldData('','Market__c',this.typeVisibility('both'),false,true,'',''),
                    new fieldData('','SupplyType__c',this.typeVisibility('both'),false,true,'',''),
                    new fieldData('','Commodity__c',this.typeVisibility('both'),false,true,'',''),
                    new fieldData('','ServicePointCode__c',this.typeVisibility('both'),false,true,'',''),
                    new fieldData('','ImplantType__c',this.typeVisibility('both'),false,true,'',''),
                    new fieldData('','SAPImplantCode__c',this.typeVisibility('both'),false,true,'',''),
                    new fieldData('','CustomerCategory__c',this.typeVisibility('both'),false,true,'',''),
                    new fieldData('','MeterSN__c',this.typeVisibility('both'),false,true,'',''),
                    new fieldData('','Resident__c',this.typeVisibility('both'),false,true,'',''),
                    new fieldData('','SapContractCode__c',this.typeVisibility('both'),false,true,'',''),
                    new fieldData('','ATO__c',this.typeVisibility('acqua'),false,true,'',''),
                    new fieldData('Disalimentabilità','Disconnectable__c',this.typeVisibility('both'),true, true, '', ''),
                    new fieldData('Categoria disalimentabilità','DisconnectibilityType__c',this.typeVisibility('both'),false, true, '', ''),
                    new fieldData('Potenza disponibile','PowerAvailable__c', this.typeVisibility('ele'), false, true,'',''),
                    new fieldData('Potenza impegnata','PowerCommitted__c', this.typeVisibility('ele'), false, true,'',''),
                    new fieldData('Tensione','VoltageLevel__c', this.typeVisibility('ele'), true, true,'',''),
                    new fieldData('Uso energia','UseTypeEnergy__c', this.typeVisibility('ele'), true, true,'',''),
                    new fieldData('Distributore','DistributorFormula__c', this.typeVisibility('both'), false, true,'',''),
                    new fieldData('Mercato di provenienza','MarketOrigin__c', this.typeVisibility('both'), true, true,'',''),
                    new fieldData('Categoria uso','UseCategory__c', this.typeVisibility('gas'), true, true,'',''),
                    new fieldData('Conferma contratto cliente','ConfirmCustomerContract__c', this.typeVisibility('ele') && this.order.Account.RecordType.DeveloperName !== 'HDT_RT_Business', false, false,'','')
                ]
            },
            {
                step: 4,
                label: 'Dati precedente intestatario',
                name: 'datiPrecedenteIntestatario',
                objectApiName: 'Order',
                recordId: this.order.Id,
                processVisibility: (this.order.RecordType.DeveloperName === 'HDT_RT_SwitchIn' && this.order.ServicePoint__r.CommoditySector__c.localeCompare('Gas') === 0) 
                                    || this.order.RecordType.DeveloperName === 'HDT_RT_VolturaConSwitch',
                data: [
                    new fieldData('Nome precedente intestatario','PreviousHolderFirstName__c', true, false, false, '',''),   
                    new fieldData('Cognome precedente intestatario','PreviousHolderLastName__c', true, false, false, '',''),   
                    new fieldData('C.F. Precdente intestatario','PreviousHolderFiscalCode__c', true, false, false, '',''),   
                    new fieldData('Ragione sociale precedente intestatario','PreviousHoldeCompanyName__c', true, false, false, '',''),   
                    new fieldData('P.Iva precedente intestatario','PreviousHolderVatNumber__c', true, false, false, '','')
                    //new fieldData('Voltura c/o VT','VolturaThirdTrader__c', this.typeVisibility('both') && this.order.RecordType.DeveloperName === 'HDT_RT_SwitchIn', false, false, '','')
                ]
            },
            {
                step: 5,
                label: 'Variabili di Processo',
                name: 'dettaglioImpianto',
                objectApiName: 'Order',
                recordId: this.order.Id,
                hasCalculateButton: this.order.RecordType.DeveloperName === 'HDT_RT_AttivazioneConModifica',
                hasCodiceAtecoButton: this.order.Account.RecordType.DeveloperName === 'HDT_RT_Business' || (this.order.RecordType.DeveloperName === 'HDT_RT_CambioUso' && (this.order.SupplyType__c !== null && this.order.SupplyType__c === 'Non Domestico')),
                processVisibility: this.order.RecordType.DeveloperName === 'HDT_RT_Subentro' || this.order.RecordType.DeveloperName === 'HDT_RT_Attivazione'
                || this.order.RecordType.DeveloperName === 'HDT_RT_AttivazioneConModifica' || this.order.RecordType.DeveloperName === 'HDT_RT_SwitchIn'
                || this.order.RecordType.DeveloperName === 'HDT_RT_CambioOfferta' || this.order.RecordType.DeveloperName === 'HDT_RT_CambioUso'
                || this.order.RecordType.DeveloperName === 'HDT_RT_ConnessioneConAttivazione' || this.order.RecordType.DeveloperName === 'HDT_RT_TemporaneaNuovaAtt',
               data: [
                new fieldData('Disalimentabilità','Disconnectable__c', this.typeVisibility('both'), false, false, '',''),
                new fieldData('Categoria disalimentabilità','DisconnectibilityType__c', this.typeVisibility('both'), false, false, '',''),
                new fieldData('Uso energia','UseTypeEnergy__c', this.typeVisibility('gas') || this.typeVisibility('ele'), !(this.order.RecordType.DeveloperName !== 'HDT_RT_CambioOfferta' && this.order.RecordType.DeveloperName !== 'HDT_RT_SwitchIn' && this.order.RecordType.DeveloperName !== 'HDT_RT_SwitchInVolturaTecnica'), !(this.order.RecordType.DeveloperName !== 'HDT_RT_CambioOfferta' && this.order.RecordType.DeveloperName !== 'HDT_RT_SwitchIn' && this.order.RecordType.DeveloperName !== 'HDT_RT_SwitchInVolturaTecnica'), '',''),
                new fieldData('Attivazione Anticipata','WaiverRightAfterthought__c', this.typeVisibility('both') && this.order.RecordType.DeveloperName === 'HDT_RT_SwitchIn' && this.order.Account.RecordType.DeveloperName === 'HDT_RT_Residenziale', true, (this.order.ProcessType__c == 'Switch in Ripristinatorio' || this.loginChannel == 'SPORTELLO') && !this.isNoDayAfterthought, this.isNoDayAfterthought , '',''),
                new fieldData('Azione commerciale','CommercialAction__c', this.typeVisibility('ele') || this.typeVisibility('gas') , false, false, '',''),
                new fieldData('Note per il DL','CommentForDL__c', this.typeVisibility('both'), false, false, '',''),
                new fieldData('Unita Immobiliari','RealEstateUnit__c', this.typeVisibility('acqua')  && ( this.order.RecordType.DeveloperName === 'HDT_RT_CambioOfferta' || this.order.RecordType.DeveloperName === 'HDT_RT_Subentro' || this.order.RecordType.DeveloperName === 'HDT_RT_Attivazione' ) , false, false, '','',
                    function(event){
                        checkHousingUnitRateCategory(event.target.value, this.order.RateCategory__c );
                    }
                ),
                new fieldData('','SupplyAddressFormula__c',this.typeVisibility('acqua'),false,true,'',''),
                new fieldData('Esclusione dal deposito cauzionale','SecurityDepositExcluded__c', this.typeVisibility('both') && (this.order.RecordType.DeveloperName === 'HDT_RT_Subentro' || this.order.RecordType.DeveloperName === 'HDT_RT_SwitchIn' || this.order.RecordType.DeveloperName === 'HDT_RT_AttivazioneConModifica' || this.order.RecordType.DeveloperName === 'HDT_RT_CambioOfferta'), false, false, '','No'),
                new fieldData('Data Inizio Connessione Temporanea','TemporaryConnectionStartDate__c', this.typeVisibility('ele') &&  this.order.RecordType.DeveloperName === 'HDT_RT_TemporaneaNuovaAtt', true, false, '',''),
                new fieldData('Data fine connessione temporanea','TemporaryConnectionEndDate__c', this.typeVisibility('ele') &&  this.order.RecordType.DeveloperName === 'HDT_RT_TemporaneaNuovaAtt', true, false, '',''),
                new fieldData('Ore di utilizzo','HoursOfUse__c', this.typeVisibility('ele') &&  this.order.RecordType.DeveloperName === 'HDT_RT_TemporaneaNuovaAtt', true, false, '',''),
                new fieldData('Potenzialità massima richiesta','MaxRequiredPotential__c', this.typeVisibility('gas') && this.order.RecordType.DeveloperName !== 'HDT_RT_SwitchIn' , this.order.RecordType.DeveloperName === 'HDT_RT_Attivazione' || this.order.RecordType.DeveloperName === 'HDT_RT_Subentro', false, '',''),
                new fieldData('Classe prelievo','WithdrawalClass__c',  this.typeVisibility('gas'), this.order.RecordType.DeveloperName !== 'HDT_RT_CambioOfferta', this.order.RecordType.DeveloperName === 'HDT_RT_CambioOfferta', '',''),
                new fieldData('ConnectionMandate__c','ConnectionMandate__c', this.typeVisibility('ele') && (this.order.RecordType.DeveloperName !== 'HDT_RT_CambioOfferta' && this.order.RecordType.DeveloperName !== 'HDT_RT_TemporaneaNuovaAtt'), false, this.order.RecordType.DeveloperName === 'HDT_RT_SwitchIn' || this.order.RecordType.DeveloperName === 'HDT_RT_SwitchInVolturaTecnica', '',''),
                new fieldData('Fase richiesta','RequestPhase__c', this.typeVisibility('ele') && this.order.RecordType.DeveloperName !== 'HDT_RT_SwitchIn' && this.order.RecordType.DeveloperName !== 'HDT_RT_CambioOfferta', true, false, '',''),
                new fieldData('Muc', 'IsMuc__c', !this.typeVisibility('acqua') && this.order.RecordType.DeveloperName === 'HDT_RT_CambioOfferta',false,this.permissionFlag, '',''),
                new fieldData('Addebito Spese Contrattuali','ContractExpenses__c', this.typeVisibility('acqua') && this.rateCategoryVisibility(rateCategories.AQCNSANNOF), false, false, '',''),
                new fieldData('Data Differita','DeferredDate__c', this.typeVisibility('acqua') && (this.order.RecordType.DeveloperName === 'HDT_RT_Attivazione' || this.order.RecordType.DeveloperName === 'HDT_RT_Subentro') , false, false, '',''),
                new fieldData('Data Decorrenza','EffectiveDate__c', this.typeVisibility('acqua'), true, false, '',''),
                new fieldData('','SendRequestDate__c', this.typeVisibility('acqua'), false, false, '',''),
                new fieldData('','RetroactiveDate__c', this.typeVisibility('acqua') &&  this.order.RecordType.DeveloperName === 'HDT_RT_CambioOfferta', false, false, '',''),
                new fieldData('Note','Note__c', this.typeVisibility('acqua') && (this.order.RecordType.DeveloperName === 'HDT_RT_ConnessioneConAttivazione' || this.order.ProcessType__c === 'Voltura - Subentro Scarico produttivo' ), false, false, '',''),
                new fieldData('Tipo impianto','ImplantType__c', this.typeVisibility('both'), this.order.ProcessType__c!=='Prima Attivazione Ele' && this.order.RecordType.DeveloperName !== 'HDT_RT_SwitchIn' && this.order.RecordType.DeveloperName !== 'HDT_RT_SwitchInVolturaTecnica', (this.order.ProcessType__c==='Prima Attivazione Ele' || this.order.RecordType.DeveloperName === 'HDT_RT_SwitchIn' || this.order.RecordType.DeveloperName === 'HDT_RT_SwitchInVolturaTecnica' || this.typeVisibility('acqua') ),'',''),
                new fieldData('Codice Ateco','AtecoCode__c', this.typeVisibility('both'), false, true, '',''),
                new fieldData('SurfaceServed__c','SurfaceServed__c', this.typeVisibility('gas') && (this.order.RecordType.DeveloperName === 'HDT_RT_Attivazione' || this.order.RecordType.DeveloperName === 'HDT_RT_Subentro' || this.order.RecordType.DeveloperName === 'HDT_RT_SwitchIn' || this.order.RecordType.DeveloperName === 'HDT_RT_CambioOfferta'), true, false, '',''),
                new fieldData('','IntendedUse__c', this.typeVisibility('both') && this.order.RecordType.DeveloperName === 'HDT_RT_ConnessioneConAttivazione' , true, false, '',''),
                new fieldData('Convenzione/Associazione','ConventionAssociation__c', ( this.typeVisibility('ele') || this.typeVisibility('gas') ) && (this.order.RecordType.DeveloperName !== 'HDT_RT_CambioOfferta' || this.order.RecordType.DeveloperName !== 'HDT_RT_TemporaneaNuovaAtt') && this.order.Account.RecordType.DeveloperName === 'HDT_RT_Business', false, false, '',''),
                new fieldData('Livello pressione','PressureLevel__c', this.typeVisibility('gas'), true, false, '',''),
                new fieldData('Servizio Energetico','EnergyService__c', this.typeVisibility('gas') && (this.order.RecordType.DeveloperName === 'HDT_RT_Subentro' || this.order.RecordType.DeveloperName === 'HDT_RT_SwitchIn' || this.order.RecordType.DeveloperName === 'HDT_RT_Attivazione'), false, false, '',''),
                new fieldData('Tipo Voltura','VoltureType__c', this.typeVisibility('both') && this.order.RecordType.DeveloperName === 'HDT_RT_VolturaConSwitch', true, false, '',''),
                new fieldData('','ContractReference__c', this.typeVisibility('acqua') && this.order.ProcessType__c === 'Voltura - Subentro Scarico produttivo', false, true, '',''),
                new fieldData('POD/PdR','ServicePointCodeFormula__c', this.typeVisibility('both'), false, true, '',''),
                new fieldData('','NotDisconnectabilityCustomer__c', this.typeVisibility('both') && this.rateCategoryVisibility(rateCategories.AF_NODISAL), false, false, '',''),
                new fieldData('','SupplyUseType__c', this.typeVisibility('acqua') && this.order.RecordType.DeveloperName === 'HDT_RT_ConnessioneConAttivazione', false, false, '','ACQUEDOTTO CIVILE'),
                new fieldData('','SeasonUse__c', this.typeVisibility('both') && this.rateCategoryVisibility(rateCategories.ZGEWKEY), this.rateCategoryVisibility(rateCategories.ZGEWKEYreq), false, '',''),
                new fieldData('','ForfaitSewer__c', this.typeVisibility('both') && this.rateCategoryVisibility(rateCategories.AQVOL_FORF), false, false, '',''),
                new fieldData('','HydrantMouthsNumber__c', this.typeVisibility('both') && this.rateCategoryVisibility(rateCategories.AF_BOC_IDR), this.rateCategoryVisibility(rateCategories.AF_BOC_IDRreq), false, '',''),
                new fieldData('','NumerousComunity__c', this.typeVisibility('both') && this.rateCategoryVisibility(rateCategories.AFNUM_COMP), false, true, '',''),
                new fieldData('','DomesticResidentNumber__c', this.typeVisibility('both') && this.rateCategoryVisibility(rateCategories.AFNCOMP), this.rateCategoryVisibility(rateCategories.AFNCOMPreq), false, '',''),
                new fieldData('','PayPurification__c', this.typeVisibility('acqua'), false, false, '',''),
                new fieldData('','PaySewer__c', this.typeVisibility('acqua'), false, false, '',''),
                new fieldData('','NotResidentDomesticHousingUnit__c', this.typeVisibility('both') && this.rateCategoryVisibility(rateCategories.AFUADNR), this.rateCategoryVisibility(rateCategories.AFUADNRreq), false, '',''),
                new fieldData('','ResidentDomesticHousingUnit__c', this.typeVisibility('both') && this.rateCategoryVisibility(rateCategories.AFUADRS), false, true, '','1'),
                new fieldData('','NotDomesticHousingUnit__c', 
                    this.typeVisibility('both') && !(this.order.RecordType.DeveloperName === 'HDT_RT_Subentro') && ( this.rateCategoryVisibility(rateCategories.AFUND) || this.rateCategoryVisibility(rateCategories.AFUNDA) || 
                    this.rateCategoryVisibility(rateCategories.AFUNDC) ), 
                    ( this.rateCategoryVisibility(rateCategories.AFUND) && this.rateCategoryVisibility(rateCategories.AFUNDreq) ) ||
                    ( this.rateCategoryVisibility(rateCategories.AFUNDA) && this.rateCategoryVisibility(rateCategories.AFUNDAreq) ) ||
                    ( this.rateCategoryVisibility(rateCategories.AFUNDC) && this.rateCategoryVisibility(rateCategories.AFUNDCreq) ) , false, '',''),
                new fieldData('','IndustrialHousingUnit__c', this.typeVisibility('acqua') && this.rateCategoryVisibility(rateCategories.AFUNDI), false, false, '',''),
                new fieldData('','ZootechnicalHousingUnit__c', this.typeVisibility('acqua') && this.rateCategoryVisibility(rateCategories.AFUNDZ), false, false, '',''),
                new fieldData('','CommercialHousingUnit__c', this.typeVisibility('acqua') && this.rateCategoryVisibility(rateCategories.AFUNAC), false, false, '',''),
                new fieldData('Tipo Mercato','Market__c', this.typeVisibility('gas') || this.typeVisibility('ele'), false, true, '',''),
                new fieldData('Settore merceologico','CommodityFormula__c', this.typeVisibility('both'), false, true, '',''),
                new fieldData('Distributore','DistributorFormula__c', this.typeVisibility('both'), false, true, '',''),
                new fieldData('Mercato di provenienza','MarketOrigin__c', this.typeVisibility('both'), false, true, '',''),
                new fieldData('Consumi Anno','AnnualConsumption__c', this.typeVisibility('both') /* && this.rateCategoryVisibility(rateCategories.AQCNSANNOF) */, false, true, '',''),
                new fieldData('Tipo Fornitura','SupplyType__c', this.typeVisibility('acqua'), true, false, '',''),
                new fieldData('ATO','ATO__c', this.typeVisibility('acqua'), false, true, '',''),
                new fieldData('','QuotationType__c', this.typeVisibility('acqua') && this.order.RecordType.DeveloperName === 'HDT_RT_ConnessioneConAttivazione', false, false, '','Analitico'),
                new fieldData('Conto contrattuale','ContractAccountCode__c', this.typeVisibility('acqua'), false, true, '',''),
                new fieldData('Tariffa','RateCategory__c', this.typeVisibility('acqua'), false, true, '',''),
                new fieldData('Classe Contatore','MeterClass__c', this.typeVisibility('acqua'), false, true, '',''),
                new fieldData('Comunità Posti Letto','ComPostiLetto__c', this.typeVisibility('acqua') && this.order.RecordType.DeveloperName === 'HDT_RT_ConnessioneConAttivazione', false, false, '',''),
                new fieldData('Potenza impegnata','PowerCommitted__c', this.typeVisibility('ele'), false, true, '',''),
                new fieldData('Potenza disponibile','PowerAvailable__c', this.typeVisibility('ele'), false, true, '',''),
                new fieldData('Potenza richiesta','PowerRequested__c', this.typeVisibility('ele'), false, this.order.RecordType.DeveloperName === 'HDT_RT_SwitchIn', '',''),
                new fieldData('Tensione','VoltageLevel__c', this.typeVisibility('ele'), false, true, '',''),
                new fieldData('Recapito telefonico','DisconnectibilityPhone__c', this.typeVisibility('ele') || this.typeVisibility('gas'), false, true, '',''),
                new fieldData('Conferma contratto cliente','ConfirmCustomerContract__c', this.typeVisibility('ele') && (this.order.Account.RecordType.DeveloperName !== 'HDT_RT_Business' && this.order.RecordType.DeveloperName === 'HDT_RT_CambioUso' || this.order.RecordType.DeveloperName === 'HDT_RT_TemporaneaNuovaAtt'), false, false, '',''),
                new fieldData('Residente all\'indirizzo di Fornitura','Resident__c', this.typeVisibility('both'), false, true, '',''),
                new fieldData('Misuratore','MeterSN__c', this.typeVisibility('both'), false, true, '',''),
                new fieldData('Categoria uso','UseCategory__c', this.typeVisibility('gas') || this.typeVisibility('ele'), this.typeVisibility('acqua'), !this.typeVisibility('acqua'), '',''),
                new fieldData('Classe Contatore','Caliber__c', this.typeVisibility('gas'), false, true, '',''),
                new fieldData('Località/Codice REMI','RemiCode__c', this.typeVisibility('gas'), false, true, '',''),
                new fieldData('Autocert. contr connessione','SelfCertificationConnection__c', this.typeVisibility('ele') && (this.order.RecordType.DeveloperName !== 'HDT_RT_CambioOfferta' && this.order.RecordType.DeveloperName !== 'HDT_RT_TemporaneaNuovaAtt' ), false, this.order.RecordType.DeveloperName === 'HDT_RT_SwitchIn' || this.order.RecordType.DeveloperName === 'HDT_RT_SwitchInVolturaTecnica', '',''),
                new fieldData('Recapito telefonico','PhoneNumber__c', this.typeVisibility('both'), false, true, '',''),
                new fieldData('Autocert Instanza','InstanceSelfCertification__c', this.typeVisibility('ele') && this.order.RecordType.DeveloperName !== 'HDT_RT_CambioOfferta', false, true, '',''),
                new fieldData('SAPImplantCode__c','SAPImplantCode__c', this.typeVisibility('both') && (this.order.RecordType.DeveloperName === 'HDT_RT_Attivazione' || this.order.RecordType.DeveloperName === 'HDT_RT_AttivazioneConModifica' || this.order.RecordType.DeveloperName === 'HDT_RT_Subentro'), false, true, '',''),
                new fieldData('ConnectionType__c','ConnectionType__c', this.typeVisibility('ele') && (this.order.RecordType.DeveloperName !== 'HDT_RT_CambioOfferta' || this.order.RecordType.DeveloperName !== 'HDT_RT_TemporaneaNuovaAtt'), true, this.order.ProcessType__c==='Prima Attivazione Ele' || this.order.RecordType.DeveloperName === 'HDT_RT_SwitchIn' || this.order.RecordType.DeveloperName === 'HDT_RT_SwitchInVolturaTecnica', '',''),
                new fieldData('Preavviso di recesso (numerico)','RecessNotice__c',this.typeVisibility('both') && this.order.RecordType.DeveloperName === 'HDT_RT_SwitchIn' && this.order.Account.RecordType.DeveloperName === 'HDT_RT_Business', true, false, '',''),
                new fieldData('Società di vendita','SalesCompany__c', this.typeVisibility('both'), false, true, '',''),
                new fieldData('Opzione richiesta','RequestOption__c', this.typeVisibility('ele') && (this.order.RecordType.DeveloperName !== 'HDT_RT_CambioOfferta'), true, this.order.RecordType.DeveloperName !== 'HDT_RT_TemporaneaNuovaAtt', '',''),
                new fieldData('Tipo Apparechiatura','MeterType__c',this.typeVisibility('ele') && (this.order.RecordType.DeveloperName === 'HDT_RT_CambioUso' || this.order.RecordType.DeveloperName === 'HDT_RT_CambioOfferta' || this.order.RecordType.DeveloperName === 'HDT_RT_TemporaneaNuovaAtt'),false, true, '','')
               ]
            },
            {
                step: 6,
                label: 'Autolettura',
                name: 'reading',
                objectApiName: '',
                recordId: '',
                isReading: true,
                processVisibility: this.order.RecordType.DeveloperName === 'HDT_RT_Voltura' || ( this.order.RecordType.DeveloperName === 'HDT_RT_CambioOfferta' && this.order.ServicePoint__r.CommoditySector__c==='Acqua')
            },
            {
                step: 5,
                label: 'Riepilogo Dati',
                name: 'riepilogoDatiAmend',
                objectApiName: 'Order',
                recordId: this.order.Id,
                processVisibility: this.order.RecordType.DeveloperName === 'HDT_RT_ScontiBonus' || this.order.VasSubtype__c === 'Analisi Consumi',
                data: [
                    new fieldData('Azione commerciale','CommercialAction__c',this.typeVisibility('both'),false, false, '',''),
                    new fieldData('Data Decorrenza','EffectiveDate__c',this.typeVisibility('both'),false, false, '',''),  
                    new fieldData('Numero Contratto','ContractReference__c',true,false, true, '',''), 
                    new fieldData('Uso energia','UseTypeEnergy__c',this.order.ServicePoint__c,false, true, '',''),                  
                    new fieldData('POD/PDR','ServicePointCode__c',this.order.ServicePoint__c,false, true, '',''),  
                    new fieldData('Tipo VAS','VASType__c', true, false, true, ''),
                    new fieldData('Categoria Cliente','CustomerCategory__c', true, false, true, ''),
                    new fieldData('Recapito Telefonico','PhoneNumber__c', true, false, true, ''),
                    new fieldData('Soc Vendita','SalesCompany__c', true, false, true, ''),
                ]
            },
            {
                step: 6,
                label: 'Analisi Consumi',
                name: 'analisiConsumi',
                objectApiName: 'OrderItem',
                recordId: this.analisiConsumi.Id !== undefined ? this.analisiConsumi.Id : '',//this.analisiConsumi.Id
                processVisibility: this.order.VasSubtype__c === 'Analisi Consumi',
                data: [
                    new fieldData('Proprietario','OwnerAC__c',this.typeVisibility('both'),false, false, '',''), 
                    new fieldData('Tipo Casa','DwellingType__c',this.typeVisibility('both'),false, false, '',''),                  
                    new fieldData('N. Abitanti','OccupantsNumber__c',this.typeVisibility('both'),false, false, '',''),
                    new fieldData('Mq. Casa','Surface__c',this.typeVisibility('both'),false, false, '','')
                ]
            },            
            {
                step: 7,
                label: 'Indirizzo di fornitura',
                name: 'indirizzoFornitura',
                objectApiName: 'Order',
                recordId: this.order.Id,
                processVisibility : ['HDT_RT_ScontiBonus' , 'HDT_RT_Subentro', 'HDT_RT_Attivazione' , 'HDT_RT_AttivazioneConModifica',
                        'HDT_RT_SwitchIn' , 'HDT_RT_CambioOfferta', 'HDT_RT_CambioUso' , 'HDT_RT_ConnessioneConAttivazione',
                        'HDT_RT_TemporaneaNuovaAtt' , 'HDT_RT_Voltura', 'HDT_RT_VolturaConSwitch' , 'HDT_RT_SubentroAmbiente',
                        'HDT_RT_AgevolazioniAmbiente', "HDT_RT_CambioTariffa", "HDT_RT_AttivazioneAmbiente", 
                        "HDT_RT_ModificaTariffaRimozione"].includes(this.order.RecordType.DeveloperName),
                data: [
                    new fieldData('Comune','SupplyCity__c', this.typeVisibility('both'), false, true, '',''),                  
                    new fieldData('Via','SupplyStreetName__c', this.typeVisibility('both'), false, true, '',''),                  
                    new fieldData('Civico','SupplyStreetNumber__c', this.typeVisibility('both'), false, true, '',''),                  
                    new fieldData('Barrato','SupplyStreetNumberExtension__c', this.typeVisibility('both'), false, true, '',''),                  
                    new fieldData('Localita','SupplyPlace__c', this.typeVisibility('both'), false, true, '',''),                  
                    new fieldData('Provincia','SupplyState__c', this.typeVisibility('both'), false, true, '',''),                  
                    new fieldData('Cap','SupplyPostalCode__c', this.typeVisibility('both'), false, true, '',''),                  
                    new fieldData('Nazione','SupplyCountry__c', this.typeVisibility('both'), false, true, '',''),                  
                    new fieldData('Codice Istat','SupplyCityCode__c', this.typeVisibility('both'), false, true, '','')
                ]
            },
            {
                step: '',
                label: this.order.Account.RecordType.DeveloperName === 'HDT_RT_Residenziale' ? 'Indirizzo di residenza' : 'Indirizzo sede legale',
                name: 'indirizzoResidenzaOsedeLegale',
                objectApiName: 'Account',
                recordId: this.order.AccountId,
                processVisibility: ['HDT_RT_Subentro' ,'HDT_RT_Attivazione'  ,'HDT_RT_AttivazioneConModifica' ,'HDT_RT_SwitchIn',
                    'HDT_RT_CambioUso' ,'HDT_RT_ConnessioneConAttivazione' , 'HDT_RT_TemporaneaNuovaAtt' ,'HDT_RT_CambioOfferta',
                    'HDT_RT_Voltura' ,'HDT_RT_VolturaConSwitch' ,'HDT_RT_SubentroAmbiente' ,'HDT_RT_AgevolazioniAmbiente',
                    "HDT_RT_CambioTariffa", "HDT_RT_AttivazioneAmbiente", "HDT_RT_ModificaTariffaRimozione"].includes(this.order.RecordType.DeveloperName),
                data: [
                    new fieldData('Comune','BillingCity', this.typeVisibility('both'), false, false, '',''),  
                    new fieldData('Via','BillingStreetName__c', this.typeVisibility('both'), false, false, '',''),  
                    new fieldData('Civico','BillingStreetNumber__c', this.typeVisibility('both'), false, false, '',''),  
                    new fieldData('Barrato','BillingStreetNumberExtension__c', this.typeVisibility('both'), false, false, '',''),            
                    {
                        'label': 'Localita',
                        'apiname': 'BillingPlace__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': false,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Provincia',
                        'apiname': 'BillingState',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': false,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Cap',
                        'apiname': 'BillingPostalCode',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': false,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Nazione',
                        'apiname': 'BillingCountry',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': false,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Codice Istat',
                        'apiname': 'BillingCityCode__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': false,
                        'value': '',
                        'processVisibility': ''
                    }
                ]
            },
            {
                step: '',
                label: 'Fatturazione elettronica',
                name: 'fatturazioneElettronicaClienteNonResidenziale',
                objectApiName: 'Order',
                recordId: this.order.Id,
                processVisibility: (this.order.RecordType.DeveloperName === 'HDT_RT_Subentro' || this.order.RecordType.DeveloperName === 'HDT_RT_Attivazione'
                || this.order.RecordType.DeveloperName === 'HDT_RT_AttivazioneConModifica' || this.order.RecordType.DeveloperName === 'HDT_RT_SwitchIn'
                || this.order.RecordType.DeveloperName === 'HDT_RT_CambioOfferta' || this.order.RecordType.DeveloperName === 'HDT_RT_CambioUso'
                || this.order.RecordType.DeveloperName === 'HDT_RT_ConnessioneConAttivazione' || this.order.RecordType.DeveloperName === 'HDT_RT_TemporaneaNuovaAtt'
                || this.order.RecordType.DeveloperName === 'HDT_RT_Voltura' || this.order.RecordType.DeveloperName === 'HDT_RT_VolturaConSwitch')
                && this.order.Account.RecordType.DeveloperName === 'HDT_RT_Business',
                data:[
                    {
                        'label': 'Codice Destinatario',
                        'apiname': 'SubjectCode__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'PEC Fatturazione Elettronica',
                        'apiname': 'InvoiceCertifiedEmailAddress__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Modalità invio Fatturazione',
                        'apiname': 'ElectronicInvoicingMethod__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Tipo invio fattura XML',
                        'apiname': 'XMLType__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'CIG',
                        'apiname': 'CIG__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'CUP',
                        'apiname': 'CUP__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Data inizio Validità Codice Destinatario',
                        'apiname': 'SubjectCodeStartDate__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Note',
                        'apiname': 'PraxidiaNote__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    }
                ]
            },
            {
                step: 5,
                label: 'Dettaglio Dati',
                name: 'dettaglioImpianto',
                objectApiName: 'Order',
                recordId: this.order.Id,
                processVisibility: this.order.RecordType.DeveloperName === 'HDT_RT_VAS' && this.order.VasSubtype__c !== 'Analisi Consumi',
                data: [
                    new fieldData('Azione Commerciale',     'CommercialAction__c',  true, false, false, ''),
                    new fieldData('Attivazione Anticipata', 'IsEarlyActivation__c', true, false, this.order.VASType__c == 'VAS Servizio', ''),
                    new fieldData('Ordine di riferimento',  'OrderReference__c',    true, false, true, ''),
                    new fieldData('Società di vendita',     'SalesCompany__c',      true, false, true, ''),
                    new fieldData('Campagna',               'Campaign__c',          true, false, true, ''),
                    new fieldData('Categoria Cliente',      'CustomerCategory__c',  true, false, true, ''),
                    new fieldData('POD/PDR',                'ServicePointCode__c',  true, false, true, ''),
                    new fieldData('Tipo VAS',               'VASType__c',           true, false, true, ''),
                    new fieldData('Sottotipo VAS',          'VasSubtype__c',        true, false, true, ''),
                    new fieldData('Recapito Telefonico',    'PhoneNumber__c',       true, false, false, '')

                ]
            },
            {
                step: 6,
                label: 'Indirizzo di attivazione',
                name: 'indirizzodiAttivazione',
                hasAddrComp: true,
                objectApiName: 'Order',
                recordId: this.order.Id,
                processVisibility: this.order.RecordType.DeveloperName === 'HDT_RT_VAS' && this.order.VasSubtype__c !== 'Analisi Consumi',
                data: [
                ]
            },
            {
                step: 7,
                label: 'Indirizzo spedizione',
                name: 'indirizzoSpedizione',
                hasAddrComp: true,
                objectApiName: 'Order',
                recordId: this.order.Id,
                processVisibility: this.order.RecordType.DeveloperName === 'HDT_RT_VAS' && this.order.VasSubtype__c !== 'Analisi Consumi',
                data: [

                ]
            },
            {
                step: 8,
                label:'Fatturazione',
                name: 'fatturazione',
                objectApiName: 'Order',
                recordId: this.order.Id,
                processVisibility: this.order.RecordType.DeveloperName === 'HDT_RT_VAS' || this.order.RecordType.DeveloperName === 'HDT_RT_Subentro' || this.order.RecordType.DeveloperName=="HDT_RT_ScontiBonus"
                || this.order.RecordType.DeveloperName === 'HDT_RT_Attivazione' || this.order.RecordType.DeveloperName === 'HDT_RT_AttivazioneConModifica'
                || this.order.RecordType.DeveloperName === 'HDT_RT_SwitchIn' || this.order.RecordType.DeveloperName === 'HDT_RT_CambioOfferta'
                || this.order.RecordType.DeveloperName === 'HDT_RT_CambioUso' || this.order.RecordType.DeveloperName === 'HDT_RT_ConnessioneConAttivazione'
                || this.order.RecordType.DeveloperName === 'HDT_RT_TemporaneaNuovaAtt' || this.order.RecordType.DeveloperName === 'HDT_RT_Voltura'
                || this.order.RecordType.DeveloperName === 'HDT_RT_VolturaConSwitch',
                data: [
                    new fieldData('AggregateBilling__c', 'AggregateBilling__c',this.typeVisibility('both'),true,false,'',''),
                    new fieldData('Modalità Invio Bolletta', 'BillSendMode__c',this.typeVisibility('both'),false,true,'',''),
                    new fieldData('Email Invio Bolletta', 'InvoiceEmailAddress__c',this.typeVisibility('both'),false,true,'',''),
                    new fieldData('Email PEC invio Bolletta', 'InvoiceCertifiedEmailAddress__c',this.typeVisibility('both'),false,true,'',''),
                    new fieldData('SendCertifiedEmailConsentDate__c', 'SendCertifiedEmailConsentDate__c',this.typeVisibility('both'),false,true,'',''),
                    new fieldData('Destinatario Divergente', 'DivergentSubject__c',this.typeVisibility('both'),false,true,'',''),
                    new fieldData('Comune', 'BillingCity__c',this.typeVisibility('both'),false,true,'',''),
                    new fieldData('Stato', 'BillingCountry__c',this.typeVisibility('both'),false,true,'',''),
                    new fieldData('Localita', 'BillingPlace__c',this.typeVisibility('both'),false,true,'',''),
                    new fieldData('Provincia', 'BillingProvince__c',this.typeVisibility('both'),false,true,'',''),
                    new fieldData('Nome Via', 'BillingStreetName__c',this.typeVisibility('both'),false,true,'',''),
                    new fieldData('Civico', 'BillingStreetNumber__c',this.typeVisibility('both'),false,true,'',''),
                    new fieldData('CAP', 'BillingPostalCode__c',this.typeVisibility('both'),false,true,'',''),
                    new fieldData('Codice ISTAT', 'BillingCityCode__c',this.typeVisibility('both'),false,true,'','')
                ]
            },
            {
                step: 9,
                label: 'Referente Cliente Finale/Anagrafica',
                name: 'primaryContact',
                objectApiName: 'Contact',
                recordId: this.order.Contact__c !== null ? this.order.Contact__c : null,
                processVisibility: this.order.RecordType.DeveloperName === 'HDT_RT_Voltura' || this.order.RecordType.DeveloperName === 'HDT_RT_VolturaConSwitch',
                data:
                [
                    new fieldData('Nome', 'FirstName',this.typeVisibility('both'),false,true,true,''),
                    new fieldData('Cognome', 'LastName',this.typeVisibility('both'),false,true,true,''),
                    new fieldData('Codice Fiscale', 'FiscalCode__c',this.typeVisibility('both'),false,true,true,''),
                    new fieldData('Telefono Cellulare', 'MobilePhone',this.typeVisibility('both'),false,true,true,''),
                    new fieldData('Telefono Fisso', 'HomePhone',this.typeVisibility('both'),false,true,true,''),
                    new fieldData('Email', 'Email',this.typeVisibility('both'),false,true,true,''),
                    new fieldData('Email PEC', 'CertifiedEmail__c',this.typeVisibility('both'),false,true,true,'')
                ]
            },
            {
                step: 10,
                label: 'Dati Commerciali',
                name: 'commercialData',
                objectApiName: 'Order',
                recordId: this.order.Id,
                processVisibility: this.order.RecordType.DeveloperName === 'HDT_RT_Voltura' || this.order.RecordType.DeveloperName === 'HDT_RT_VolturaConSwitch',
                data:
                [
                    new fieldData('Mercato', 'Market__c',this.typeVisibility('both'),false,true,true,''),
                    new fieldData('Contratto', 'SapContractCode__c',this.typeVisibility('both'),false,true,true,''),
                    new fieldData('Punto di Fornitura', 'ServicePoint__c',this.typeVisibility('both'),false,true,true,''),
                    new fieldData('Codice Ateco', 'AtecoCode__c',this.typeVisibility('both'),false,false,true,'')
                ]
            },
            {
                step: 11,
                label:'Iva e accise',
                name: 'ivaAccise',
                objectApiName: 'Order',
                recordId: this.order.Id,
                hasIvaAcciseUploadButton: true,
                processVisibility: this.order.RecordType.DeveloperName === 'HDT_RT_Subentro' || this.order.RecordType.DeveloperName === 'HDT_RT_SwitchIn' 
                                || this.order.RecordType.DeveloperName === 'HDT_RT_Attivazione' || this.order.RecordType.DeveloperName === 'HDT_RT_AttivazioneConModifica'
                                || this.order.RecordType.DeveloperName === 'HDT_RT_ConnessioneConAttivazione' || this.order.RecordType.DeveloperName === 'HDT_RT_SwitchInVolturaTecnica' 
                                || this.order.RecordType.DeveloperName === 'HDT_RT_CambioOfferta' || this.order.RecordType.DeveloperName === 'HDT_RT_CambioUso' 
                                || this.order.RecordType.DeveloperName === 'HDT_RT_Voltura' || this.order.RecordType.DeveloperName === 'HDT_RT_VolturaConSwitch',
                data: [
                    new fieldData('Flag Agevolazione IVA','VATfacilitationFlag__c',this.typeVisibility('both'),false,this.order.RecordType.DeveloperName === 'HDT_RT_CambioOfferta' || ((this.loginChannel === 'Teleselling Inbound' || this.loginChannel === 'Teleselling Outbound' || this.loginChannel === 'Telefono Inbound' || this.loginChannel === 'Telefono Outbound') && this.order.RecordType.DeveloperName !== 'HDT_RT_CambioOfferta')  ,'', '', 
                        function(event){
                            let disableXorRequire = event?.target?.value == true;//if has value, field editable and required, else opposite
                            if(this.template.querySelector(`[data-id='VAT__c']`) !== null) {
                                this.template.querySelector(`[data-id='VAT__c']`).disabled = !disableXorRequire;
                                this.template.querySelector(`[data-id='VAT__c']`).required = disableXorRequire;
                                Promise.resolve().then(() => {
                                    const inputEle = this.template.querySelector(`[data-id='VAT__c']`);
                                    inputEle.reportValidity();
                                });
                            }
                        }
                    ),
                    new fieldData('Flag Accise Agevolata','FacilitationExcise__c',this.typeVisibility('both'),false,this.order.RecordType.DeveloperName === 'HDT_RT_CambioOfferta' || ((this.loginChannel === 'Teleselling Inbound' || this.loginChannel === 'Teleselling Outbound' || this.loginChannel === 'Telefono Inbound' || this.loginChannel === 'Telefono Outbound') && this.order.RecordType.DeveloperName !== 'HDT_RT_CambioOfferta') ,'', '',
                        function(event){
                            let disableXorRequire = event?.target?.value == true;//if has value, field editable and required, else opposite
                            for(let field of ["ExciseEle__c", "ExciseGAS__c"]){
                                if(this.template.querySelector(`[data-id='${field}']`) !== null) {
                                    this.template.querySelector(`[data-id='${field}']`).disabled = !disableXorRequire;
                                    this.template.querySelector(`[data-id='${field}']`).required = disableXorRequire;
                                    Promise.resolve().then(() => {
                                        const inputEle = this.template.querySelector(`[data-id='${field}']`);
                                        inputEle.reportValidity();
                                    });
                                }
                            }
                        }
                    ),
                    new fieldData('IVA','VAT__c',this.typeVisibility('both'),false, (this.order.RecordType.DeveloperName !== 'HDT_RT_CambioUso'),'','Iva 10% (Cod. 01)'),
                    new fieldData('Accise Agevolata Ele','ExciseEle__c',this.typeVisibility('ele'),false,(this.order.RecordType.DeveloperName !== 'HDT_RT_CambioUso'),''),
                    new fieldData('Accise Agevolata Gas','ExciseGAS__c',this.typeVisibility('gas'),false,(this.order.RecordType.DeveloperName !== 'HDT_RT_CambioUso'),''),
                    new fieldData('Aliquota Accise','ExciseRate__c',this.typeVisibility('ele'),false,true,this.order.RecordType.DeveloperName !== 'HDT_RT_SwitchIn',''),
                    new fieldData('Addizionale Regionale', 'RegionalAdditional__c',this.typeVisibility('ele'),false,true,this.order.RecordType.DeveloperName !== 'HDT_RT_SwitchIn','')
                ]
            },
            {
                step: '',
                label: 'Metodo Firma e Canale Invio',
                name: 'metodoFirma',
                objectApiName: 'Order',
                recordId: this.order.ParentOrder__c,
                processVisibility: ( this.order.RecordType.DeveloperName === 'HDT_RT_ScontiBonus' ),
                data: [
                    new fieldData('Metodo Firma','SignatureMethod__c', this.typeVisibility('both'),false, true, '',''),
                    new fieldData('Invio Doc','DocSendingMethod__c',this.typeVisibility('both'),false, true, '','' ),                  
                    new fieldData('Data Firma','SignedDate__c', this.typeVisibility('both'),false, true, '', this.order.ParentOrder__r.SignedDate__c)
                ]
            },  
            {
                step: '',
                label: 'Metodo pagamento',
                name: 'metodoPagamento',
                objectApiName: 'Order',
                recordId: this.order.Id,
                processVisibility: ['HDT_RT_Subentro', 'HDT_RT_VAS'   , 'HDT_RT_ScontiBonus' , 'HDT_RT_Attivazione' , 
                    'HDT_RT_AttivazioneConModifica' , 'HDT_RT_SwitchIn' , 'HDT_RT_CambioOfferta' , 'HDT_RT_CambioUso' , 
                    'HDT_RT_ConnessioneConAttivazione' , 'HDT_RT_TemporaneaNuovaAtt' , 'HDT_RT_Voltura' , 'HDT_RT_VolturaConSwitch',
                    'HDT_RT_SubentroAmbiente' , 'HDT_RT_AgevolazioniAmbiente', "HDT_RT_CambioTariffa",
                    "HDT_RT_AttivazioneAmbiente", "HDT_RT_ModificaTariffaRimozione"].includes(this.order.RecordType.DeveloperName),
                data: [
                    new fieldData('Modalità di Pagamento','PaymentMode__c',this.typeVisibility('both'), false, false, '',''),
                    new fieldData('IBAN Estero','IbanIsForeign__c',this.typeVisibility('both'), false, false, '',''),
                    new fieldData('Paese','IbanCountry__c',this.typeVisibility('both'), false, false, '',''),
                    new fieldData('Numeri di Controllo','IbanCIN_IBAN__c',this.typeVisibility('both'), false, false, '',''),
                    new fieldData('CIN','IbanCIN__c',this.typeVisibility('both'), false, false, '',''),
                    new fieldData('ABI','IbanABI__c',this.typeVisibility('both'), false, false, '',''),
                    new fieldData('CAB','IbanCAB__c',this.typeVisibility('both'), false, false, '',''),
                    new fieldData('Numero conto corrente','IbanCodeNumber__c',this.typeVisibility('both'), false, false, '',''),
                    new fieldData('Tipologia Intestatario','SignatoryType__c',this.typeVisibility('both'), false, false, '',''),
                    new fieldData('Codice Fiscale intestatario c/c','BankAccountSignatoryFiscalCode__c',this.typeVisibility('both'), false, false, '',''),
                    new fieldData('Nome Intestatario c/c','BankAccountSignatoryFirstName__c',this.typeVisibility('both'), false, false, '',''),
                    new fieldData('Cognome Intestario c/c','BankAccountSignatoryLastName__c',this.typeVisibility('both'), false, false, '',''),
                    new fieldData('Modalità di Fatturazione VAS','VASBillingMode__c',this.typeVisibility('both'), false, true, '','')
                ]
            },
            {
                step: 10,
                label: 'Date ordine',
                name: 'dateOrdine',
                objectApiName: 'Order',
                recordId: this.order.Id,
                processVisibility: (this.order.RecordType.DeveloperName === 'HDT_RT_CambioOfferta' || this.order.RecordType.DeveloperName === 'HDT_RT_SwitchIn') && this.order.Account.RecordType.DeveloperName === 'HDT_RT_Business',
                data: [
                    new fieldData('Data Firma','SignedDate__c',this.typeVisibility('both'), false, true, this.order.ParentOrder__r.SignedDate__c,''),
                    new fieldData('Attivazione Posticipata','IsActivationDeferred__c',this.typeVisibility('both') && this.order.RecordType.DeveloperName === 'HDT_RT_SwitchIn', false, false, '','',
                        function(event){
                            console.log("IsActivationDeferred__c");
                            this.pendingSteps.filter(section => section.name === 'dateOrdine')[0].data.filter(field => field.apiname === 'EffectiveDate__c')[0].typeVisibility = event.target.value;
                            if (event.target.value && this.sectionDataToSubmit.EffectiveDate__c === undefined) {
                                this.sectionDataToSubmit['EffectiveDate__c'] = this.order.EffectiveDate__c;
                            } else {
                                delete this.sectionDataToSubmit.EffectiveDate__c;
                            }
                        }
                    ),
                    new fieldData('Data decorrenza','EffectiveDate__c',this.typeVisibility('both') && this.order.Account.RecordType.DeveloperName === 'HDT_RT_Business', false, false, '','')
                ]
            },
            {
                lastStep: true,
                step: '',
                label: 'Metodo firma canale invio',
                name: 'metodoFirmaCanaleInvio',
                objectApiName: 'Order',
                recordId: this.order.Id,
                processVisibility: [
                    "HDT_RT_VAS", "HDT_RT_Subentro", "HDT_RT_Attivazione", "HDT_RT_AttivazioneConModifica",
                    "HDT_RT_SwitchIn", "HDT_RT_TemporaneaNuovaAtt", "HDT_RT_CambioUso", "HDT_RT_ConnessioneConAttivazione",
                    "HDT_RT_CambioOfferta", "HDT_RT_Voltura", "HDT_RT_VolturaConSwitch", "HDT_RT_SubentroAmbiente",
                    "HDT_RT_AgevolazioniAmbiente", "HDT_RT_CambioTariffa",
                    "HDT_RT_AttivazioneAmbiente", "HDT_RT_ModificaTariffaRimozione"].includes(this.order.RecordType.DeveloperName),
                data: [
                    new fieldData('Metodo firma','SignatureMethod__c',this.typeVisibility('both'), true, false, '',''),
                    new fieldData('Invio doc','DocSendingMethod__c',this.typeVisibility('both'), true, false, '','')
                ]
            }
        ];
    }

    export {handleSections, equalsIgnoreCase, safeStr}