class Util {
	constructor() {
		this.mapDelegated = {};
		this.mapInteractions = {};
	}
	createActivity(message) {
		ConnectorEntityController.createActivity(JSON.stringify(message), (result, req) => {
			if(result.startsWith("Error")) {
				// WIP IMPROVE ERROR HANDLING
				console.log("### iwsutil.createActivity() | RESULT STARTS WITH ERROR");
			} else {
				var resultObj = JSON.parse(result.replaceAll("&quot;","\""));
				iwscommand.SetAttachdataById(message.ConnectionID, {"sf_activity_id": resultObj.activityId});
				console.log("### iwsutil.createActivity() | ACTIVITY CREATED!");
				if(resultObj.accountId && resultObj.contactId) {
					this.screenpop(resultObj.accountId);
				} else {
					this.screenpop(resultObj.activityId);
				}
			}
		});
	}
	closeActivity(message, crmChange, operatorChange) {
		ConnectorEntityController.closeActivity(JSON.stringify(message), crmChange, operatorChange, (result, req) => {
			if(result.startsWith('Error')) {
				// WIP IMPROVE ERRO HANDLING
				console.log("### iwsutil.closeActivity() | RESULT STARTS WITH ERROR");
			} else {
				console.log("### iwsutil.closeActivity() | ACTIVITY CLOSED!");
			}
		});
	}
	addTabFocusListener() {
		sforce.console.onFocusedPrimaryTab(listened => {
			sforce.console.getFocusedPrimaryTabId(focused => {
				if (focused && listened && focused.id == listened.id) {
					for (let key in iwscore.mapInteractions) {
						let ixn = iwscore.mapInteractions[key];
						let id = (ixn && ixn.attachdata) ? ixn.attachdata.CONTACT_ID || ixn.attachdata.SFDC_ID || ixn.attachdata.WorkItemId || ixn.attachdata['context.WorkItemId'] : undefined;
						logsf.info("addTabFocusListener listened id: ", listened.id);
						logsf.info("addTabFocusListener id: ", id);
						if (id && id == listened.objectId) {
							iwscommand.SetInteractionOnWde(ixn.InteractionID || ixn.ConnectionID);
						}
					}
				}
			});
		});
	}
	listenToCustomEvents() {
		sforce.console.addEventListener('onBeforeUnload', (res) => {
			logsf.info("*** connector onBeforeUnload : ", res);
		});
	}
	enableClickToDial() {
		var callback = (res) => {
			log.info("click to dial response=" + JSON.stringify(res));
		};
		log.info("enabling click to dial");
		if (isLightning) {
			sforce.opencti.onClickToDial({
				listener: (payload) => {
					log.info('Clicked phone number: ' + +JSON.stringify(payload));
					if (!payload || !payload.number) {
						log.warn("The result from click to dial is not valid : " + JSON.stringify(payload));
						return;
					}
					// DEFAULT
					// iwscommand.MakeCall(payload.number, undefined);
					// CUSTOM
					var attachdata = createUserData();
					iwscommand.MakeCall('0' + payload.number, attachdata);
				}
			});
			sforce.opencti.enableClickToDial({ callback: callback });
		} else {
			log.info("setting onClickToDial");
			sforce.interaction.cti.onClickToDial(function (payload) {
				log.info('Clicked phone number: ' + JSON.stringify(payload));
				var result = JSON.parse(payload.result);
				if (!result || !result.number) {
					log.warn("The result from click to dial is not valid : " + JSON.stringify(payload));
					return;
				}
				log.info("Dialing phone number : " + result.number);
				iwscommand.MakeCall('0' + result.number, undefined);
			});
			sforce.interaction.cti.enableClickToDial(undefined);
		}
	}
	checkExists(event) {
		logsf.info("checkExists, event:", event);
		if (!event.attachdata) {
			logsf.info("the event has no attachdata, returning");
			return;
		}
		let id = event.attachdata.CONTACT_ID || event.attachdata.SFDC_ID || event.attachdata.WorkItemId || event.attachdata['context.WorkItemId'];
		if (id) {
			log.infoFormat("There is already an item associated to this interaction : {0}, opening it", id);
			this.refreshTabAndScreenpop(id);
			return true;
		}
		return false;
	}
	async refreshTabAndScreenpop(id) {
		var tabIds = await this.callApiSync(sforce.console.getPrimaryTabIds);
		var refresh = false;
		if (tabIds.success) {
			tabIds.ids.forEach(async (tabId) => {
				var objectId = await this.callApiSync(sforce.console.getPageInfo, tabId);
				if (objectId.success) {
					var pageInfo = JSON.parse(objectId.pageInfo);
					if (pageInfo.objectId && pageInfo.objectId == id) {
						sforce.console.refreshPrimaryTabById(tabId, true, res => logsf.info(res), true);
						refresh = true;
						return;
					}
				}
			});
		}
		if (refresh) {
			return;
		}
		this.screenpop(id);
	}
	screenpop(id) {
		if (isLightning) {
			sforce.opencti.screenPop({ type: sforce.opencti.SCREENPOP_TYPE.URL, params: { url: '/' + id } });
		}
		else {
			sforce.interaction.screenPop('/' + id, true, undefined);
		}
	}
	manageSwitchInteraction(event) {
		let id = event.attachdata.CONTACT_ID || event.attachdata.SFDC_ID || event.attachdata.WorkItemId || event.attachdata['context.WorkItemId'];
		if (id) {
			this.screenpop(id);
		}
	}
	callApiSync(api, ...params) {
		return $.Deferred((dfrd) => {
			if (params) {
				api(...params, dfrd.resolve);
			}
			else {
				api(dfrd.resolve);
			}
		}).promise();
	}
	createTask(event, field, id, subject) {
		if (this.checkExists(event)) {
			return;
		}
		var task = new sforce.SObject("task");
		task.Subject = subject;
		task.CallType = event.CallType;
		task.softphone_it__IWS_Interaction_ID__c = event.ConnectionID;
		task.softphone_it__IWS_Media_Name__c = event.MediaType;
		ConnectorEntityController.createTask(task, field, id, (result, req) => {
			logsf.info("result : ", result);
			logsf.info("req : ", req);
			if (req.statusCode == 200) {
				var params = { "SFDC_ID": result.Id };
				if (result.WhoId) {
					params.CONTACT_ID = result.WhoId;
				}
				iwscommand.SetAttachdataById(event.ConnectionID, params);
				event.attachdata = Object.assign(event.attachdata, params);
				iwscore.addJSONObjectInMemory(event);
				let idToScreen = result.WhoId ? result.WhoId : result.Id;
				logsf.info("idToScreen :", idToScreen);
				this.refreshTabAndScreenpop(idToScreen);
			}
		});
	}
	createCase(event, field, id, subject) {
		if (this.checkExists(event)) {
			return;
		}
		var obj = new sforce.SObject("case");
		obj.Subject = subject;
		obj.IWS_Interaction_ID__c = event.ConnectionID;
		obj.IWS_Media_Name__c = event.MediaType;
		ConnectorEntityController.createCase(obj, field, id, function (result, req) {
			logsf.info("result : ", result);
			logsf.info("req : ", req);
			if (req.statusCode == 200) {
				var params = { "SFDC_ID": result.Id };
				if (result.ContactId) {
					params.CONTACT_ID = result.WhoId;
				}
				iwscommand.SetAttachdataById(event.ConnectionID, params);
				event.attachdata = Object.assign(event.attachdata, params);
				iwscore.addJSONObjectInMemory(event);
				let idToScreen = result.ContactId ? result.ContactId : result.Id;
				logsf.info("idToScreen :", idToScreen);
				this.refreshTabAndScreenpop(idToScreen);
			}
		});
	}
	createTaskAjax(event, field, id, subject) {
		var user = sforce.connection.getUserInfo(undefined);
		if (this.checkExists(event)) {
			return;
		}
		var task = new sforce.SObject("task");
		task.OwnerId = user.userId;
		task.Subject = subject;
		task.CallType = event.CallType;
		task.softphone_it__IWS_Interaction_ID__c = event.ConnectionID;
		task.softphone_it__IWS_Media_Name__c = event.MediaType;
		logsf.info("task:", task);
		var q = "Select id,AccountId,Birthdate,Email,FirstName,LastName,Phone from Contact where {0} = \'{1}\'";
		var query = q.format(field, id);
		logsf.info("Executing query : ", query);
		var result = sforce.connection.query(query, undefined);
		var records = result.getArray("records");
		if (records && records.length == 1) {
			task.WhoId = records[0].Id;
		}
		sforce.connection.create([task], (res) => {
			logsf.info("task insert:");
			logsf.info(res);
			if (res && res.length > 0 && res[0].getBoolean("success")) {
				var params = iwscore.createUserData();
				params.put("TASK_ID", res[0].id);
				params.put("interactionId", event.ConnectionID);
				iwscommand.SetAttachdataByIdAndCustomerId(event.InteractionID, event.CustomerID, params);
				logsf.info("isLightning=" + isLightning);
				logsf.info(typeof isLightning);
				if (isLightning) {
					logsf.info("calling opencti");
					sforce.opencti.screenPop({ type: sforce.opencti.SCREENPOP_TYPE.URL, params: { url: '/' + res[0].id } });
				}
				else {
					logsf.info("calling interaction");
					sforce.interaction.screenPop('/' + res[0].id, true, (res) => {
						logsf.info("screenpop result=", res);
					});
				}
			}
		});
	}
	updateTaskDuration(event) {
		logsf.info("updateTaskDuration Event:");
		logsf.info(event);
		if (!event.Duration) {
			log.warn("The event has no duration, no update performed!");
			return;
		}
		let taskId = event.attachdata.SFDC_ID;
		var task = new sforce.SObject("task");
		task.id = taskId;
		task.CallDurationInSeconds = parseInt(event.Duration);
		let result = sforce.connection.update([task], undefined);
		if (result[0].getBoolean("success")) {
			log.info("account with id " + result[0].id + " updated");
		}
		else {
			log.error("failed to update account " + result[0]);
		}
	}
	updateConnectionLed(clazz, msg) {
		$("#led").removeClass();
		$("#led").addClass(clazz);
		$(".led-msg p").text(msg);
	}
	updateOpenCtiStatus(connected) {
		if (isLightning) {
			let icon = connected ? 'call' : 'end_call';
			sforce.opencti.setSoftphoneItemIcon({ key: icon, callback: (res) => logsf.info("result change icon : ", res) });
			sforce.opencti.setSoftphonePanelIcon({ key: icon, callback: (res) => logsf.info("result change Panel icon : ", res) });
		}
		else {
			var buttonStyle = connected ? 'background:#53e675;' : 'background:#ff3b3b;';
			sforce.console.setCustomConsoleComponentButtonStyle(buttonStyle);
		}
	}
}
const sfutil = new Util();
