from tqdm import tqdm
import os
import argparse
import codecs
import json
import re
import requests
requests.session().keep_alive = False  # 及时释放


def get_info(api_url, token):
    headers = {'Private-Token': "%s" % token}
    r = requests.get(
        api_url, headers=headers)
    ret = json.loads(r.text)
    if r.status_code > 300:
        print('error %s', r.text)
        return False
    return ret


def to_markdown(page, mk_note):
    mk = '# ' + page['title'] + '\n'
    mk += "created_at: "+page['created_at']+"\n"
    mk += "updated_at: "+page['updated_at']+"\n"

    labels = "label: "
    for idx, item in enumerate(page['labels']):
        if (idx+1) == len(page['labels']):
            labels += item+'\n'
        else:
            labels += item+','
    mk += labels+'\n'

    mk += page['description']+'\n'

    mk += mk_note
    return mk


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-p', '--id', help="gitlab project id")
    parser.add_argument('-t', '--token', help="gitlab personal access token")
    parser.add_argument('-o', '--dir', help="out put dir")

    args = parser.parse_args()

    # args.id = ?
    # args.token = ""
    # args.dir = "out"

    if not os.path.exists(args.dir):
        os.makedirs(args.dir)

    base = "https://gitlab.com/api/v4"
    # 当然你也可以自建gitlab

    issue_url = base+"/projects/%d/issues?per_page=%d"
    # gitlab默认服务器端每次只返回20条数据给客户端，可以用设置page和per_page参数的值，指定服务器端返回的数据个数。

    note_url = base+"/projects/%d/issues/%d/notes?sort=asc"

    # 包含了所有的issue both open and closed
    ret = get_info(issue_url % (args.id, 100), args.token)

    for page in tqdm(ret):
        if page['state'] == 'opened':  # 去掉关闭的issue
            _pid = page['project_id']
            _iid = page['iid']

            mk_note = ""  # 获取评价
            if page['user_notes_count'] > 0:
                notes = get_info(note_url % (_pid, _iid), args.token)
                for note in notes:
                    if not note['system']:  # 过滤系统的notes
                        mk_note += note['body']+'\n'

            mk = to_markdown(page, mk_note)

            # save
            filename = page['created_at'].split('T')[0]+','+page['title']+'.md'
            filename = re.sub(r'[/:*?"<>|]', " ", filename)  # check filename
            filename = os.path.join(args.dir, filename)

            with codecs.open(filename, 'w', 'utf-8') as file:
                file.write(mk)
