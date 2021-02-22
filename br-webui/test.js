var Git = require('nodegit');
var git_directory = '/home/jacob/git/companion'
var myRepository = null;

function connectRemote(remoteName) {
	return myRepository.getRemote(remoteName)
		.then(function(remote) {
			console.log('connecting to remote', remote.name(), remote.url());
			remote.connect(Git.Enums.DIRECTION.FETCH, {
                credentials(url, username) {
                    return Git.Cred.defaultNew();
                }
            });
		});
}

function connectRemotes(remoteNames) {
	console.log('connectRemotes', remoteNames);
	remoteNames.forEach(function(remote) {
        connectRemote(remote)
	});
}

function updateRemotes() {
	myRepository.getRemoteNames()
		.then(connectRemotes);
}

Git.Repository.open(git_directory)
	.then(function(repository) {
		myRepository = repository;
		updateRemotes();
    });
