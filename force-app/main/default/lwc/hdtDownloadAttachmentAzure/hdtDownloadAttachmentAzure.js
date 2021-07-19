import { track, LightningElement, api, wire } from 'lwc';
import getUrlNameDocumentLink from '@salesforce/apex/HDT_LC_DownloadAttachmentAzure.getUrlNameDocumentLink';

export default class Fdt_Alessio_test extends LightningElement {
    @track searchKey= '';
    @track base_url = 'https://archiviazione.azurewebsites.net/sbldownload/';

    @api recordId;

    handleDownload(){
        getUrlNameDocumentLink({rId:this.recordId})
        .then(r=>{
            this.searchKey = r;
            let url = this.base_url + r;
            console.log(url);
            let data = { method: 'GET',
                            Accept:'*/*',
                            cache: 'no-cache',
                            mode:'cors'
                        }
            fetch(url,data)
                .then(response => response.body)
                .then(body => body.getReader())
                .then(reader =>
                    new ReadableStream({
                        async start(controller) {
                            while (true) {
                            const { done, value } = await reader.read();
                    
                            // When no more data needs to be consumed, break the reading
                            if (done) {
                                break;
                            }
                    
                            // Enqueue the next data chunk into our target stream
                            controller.enqueue(value);
                            }
                      
                              // Close the stream
                              controller.close();
                              reader.releaseLock();
                            
                        }
                      })
                )
                
                .then(rs => new Response(rs))
                // Create an object URL for the response
                .then(response => response.blob())
                .then(blob => URL.createObjectURL(blob))
                // Update image
                .then(url => {
                    var link=document.createElement('a');
                    link.href=url;
                    link.download=this.searchKey+".jpeg";
                    link.click();
                })
                .catch(console.error);
        })
    }

    connectedCallback(){
        
    }
}