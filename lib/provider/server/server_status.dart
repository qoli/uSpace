enum ServerStatus {
  starting,
  running,
  uploading,
  stopped,
  error,
}

const serverStatusStringMap = {
  ServerStatus.starting: 'Starting',
  ServerStatus.running: 'Running',
  ServerStatus.uploading: 'Uploading',
  ServerStatus.stopped: 'Stopped',
  ServerStatus.error: 'Error',
};
