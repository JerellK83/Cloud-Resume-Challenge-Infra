#Visitor Counter

from flask import jsonify
from google.cloud import firestore


def get_count():
    #Get the number of visitors
    db = firestore.Client()
    visitors = 0
    doc_ref = db.collection(u'cloud_resume').document(u'visitor_count')
    doc = doc_ref.get()
    if doc.exists:
        visitors = int(doc.to_dict()['count'])
    return visitors


def save_count(visitors):
    #Save the number of visitors to Firestore
    db = firestore.Client()
    doc_ref = db.collection(u'cloud_resume').document(u'visitor_count')
    doc_ref.set({'count': visitors})


def visitor_count(request):
    #Return the current visitor number to the client request
    visitors = get_count()
    current_visitor = str(visitors + 1)
    save_count(current_visitor)
    client_data = {
        'currentVisitor': current_visitor
    }
    headers = {
        'Access-Control-Allow-Origin': '*'
    }
    return jsonify(client_data), 200, headers