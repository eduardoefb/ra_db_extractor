import pysftp

with pysftp.Connection('10.20.0.2', username='SYSTEM', password='SYSTEM') as sftp:
    with sftp.cd('/ASG_6_11_0/LICENCE'):           # temporarily chdir to allcode        
        sftp.get('*.XML')         # get a remote file
