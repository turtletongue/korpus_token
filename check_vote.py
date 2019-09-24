

import hashlib
vote_list = []
candidate_list = []
trueVotes = 0
votesCount = len(vote_list) // 11
for i in range(votesCount):
    preHash = str(vote_list[1]) + str(vote_list[2]) + str(vote_list[3]) + str(vote_list[4]) + str(vote_list[5]) + str(vote_list[6])
    result = hashlib.md5()
    result.update(preHash.encode('utf-8'))
    result = result.hexdigest()
    if result == vote_list[0]:
        trueVotes += 1
    candidate_list.append(vote_list[4])
    for x in range(11):
      vote_list.pop(0)
if trueVotes == votesCount:
    print('True')