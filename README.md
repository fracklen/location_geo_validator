
## Raketask cronjob
```
30 1 * * * cd /root/location_validator && /root/.rbenv/shims/rake validate:coordinates
```
"updates": {
    "with_ts": "function(doc, req){ if(!doc){ var new_doc=JSON.parse(req.body); new_doc._id = req.uuid; new_doc['ts'] = new Date().toISOString(); new_doc.user_agent=req.headers['User-Agent']; return [new_doc,'added new'];} }"
