import { track, LightningElement, api, wire } from 'lwc';
import getUrlNameDocumentLink from '@salesforce/apex/HDT_LC_DownloadAttachmentArchive.getUrlNameDocumentLink';
import getExtensionFile from '@salesforce/apex/HDT_LC_DownloadAttachmentArchive.getExtensionFile';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';  //Modifica>>> marco.arci@webresults.it 22/09/21
export default class Fdt_Alessio_test extends NavigationMixin(LightningElement) {
    @track searchKey= '';
    @track fileName= '';
    @track base_url = '';
    @track extension = false;       //Modifica 12/10/21 marco.arci@webresults.it true= cliccabile, false= non cliccabile
    
    @api recordId;

    handleDownload(){
        console.log('-----log_Start');
        getUrlNameDocumentLink({rId:this.recordId})
        .then(r=>{
            console.log('-----log_first then', r);
            console.log('-----fileExist? ', r.fileExist);
            if('true' == r.fileExist){
                this.base_url = r.endpoint + '/sbldownload/';
                this.searchKey = r.NOME_FILE_DOWNLOAD__c;
                this.fileName= r.FILE_NAME__c +'.'+ r.FILE_EXT__c;
                let url = this.base_url+this.searchKey;
                //let url = r.endpoint+'/sbldownload/'+this.searchKey;
                console.log(url);

                this[NavigationMixin.Navigate]({
                    "type": "standard__webPage",
                    "attributes": {
                        "url": url
                    }
                });
            } else {
                this.showToast('Attenzione!', 'Allegato NON presente', null, 'warning','dismissable');
            }
            let data = { method: 'GET',
                             Accept:'*/*',
                            cache: 'no-cache',
                            mode:'cors'
                        }
                    
            //START Modifica>>> marco.arci@webresults.it 10/11/21
            /*
            fetch(url,data)
                .then(response => {
                    console.log(response.status);
                    return response.status!=404 ? response.body : null;
                })
                .then(body => {
                    return body!=null ? body.getReader() : null;
                })
                .then(reader => {
                    if (reader != null){
                        var abc = new ReadableStream({
                        async start(controller) {
                            console.log('-----log_in to async start');
                            while (true) {
                                const { done, value } = await reader.read();
                        
                                // When no more data needs to be consumed, break the reading
                                if (done) {
                                    //console.log('i del break: '+this.i);
                                    break;
                                }
                        
                                // Enqueue the next data chunk into our target stream
                                controller.enqueue(value);
                                //this.i=true;
                            }
                    
                            // Close the stream
                            controller.close();
                            reader.releaseLock();
                        }
                        });
                        return abc;
                    }else{
                        return null;
                    }
                })
                .then(rs => {
                    return rs != null ? new Response(rs) : null;
                })
                // Create an object URL for the response
                .then(response => {
                    return response != null ? response.blob() : null;
                })
                .then(blob => {
                    return blob != null ? URL.createObjectURL(blob) : null;
                })
                // Update image
                .then(url => {
                    if(url != null){
                        var link=document.createElement('a');
                        link.href=url;
                        link.download=this.fileName;
                        link.click();
                    }else{
                        console.log('-----log_in last else toast');
                        this.showToast('Attenzione!', 'Allegato NON presente', null, 'warning','dismissable');
                    }
                })
                .catch((error)=>{
                    console.log('-----log_in to catch');
                    console.error(error);
                    this.showToast('Attenzione!', 'Allegato NON presente', null, 'warning','dismissable');
                })
                */
                //END Modifica>>> marco.arci@webresults.it 10/11/21
        })
    }

    //START Modifica>>> marco.arci@webresults.it 22/09/21
    showToast(title, message, messageData, variant, mode) { 
 
        const event = new ShowToastEvent({title: title, 
                                          message: message, 
                                          messageData: messageData, 
                                          variant: variant, 
                                          mode: mode 
        }); 
        this.dispatchEvent(event); 
    }
    //END Modifica>>> marco.arci@webresults.it 22/09/21

    //Strat>>> Modifica 12/10/21 marco.arci@webresults.it chiamata ad apex se l'estensione è url o meno (Url=flase, else=true)
    async checkExtensionForButtonType(){
        this.extension = await getExtensionFile({rId:this.recordId});
    }
    //End>>> Modifica 12/10/21 marco.arci@webresults.it chiamata ad apex se l'estensione è url o meno (Url=flase, else=true)

    connectedCallback(){
        this.checkExtensionForButtonType();  //>>> Modifica 12/10/21 marco.arci@webresults.it chiamata metodo per scelta tipo pulsante
    }
}