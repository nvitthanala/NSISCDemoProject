import React, { useEffect, useState, useMemo } from 'react';

// --- MATH & CONVERSION HELPERS ---
const formatDisplayTime = (totalSeconds: number) => {
  if (totalSeconds < 60) return totalSeconds.toFixed(2);
  const minutes = Math.floor(totalSeconds / 60);
  const seconds = (totalSeconds % 60).toFixed(2);
  const paddedSeconds = parseFloat(seconds) < 10 ? `0${seconds}` : seconds;
  return `${minutes}:${paddedSeconds}`;
};

const parseInputTime = (timeStr: string) => {
  const parts = timeStr.split(':');
  if (parts.length === 2) {
    return parseInt(parts[0], 10) * 60 + parseFloat(parts[1]);
  }
  return parseFloat(parts[0]);
};

const CONVERSION_FACTORS: Record<string, { SCM: number; LCM: number }> = {
  '50Y Free': { SCM: 0.896, LCM: 0.875 },
  '100Y Free': { SCM: 0.896, LCM: 0.876 },
  '200Y Free': { SCM: 0.895, LCM: 0.874 },
  '500Y Free': { SCM: 1.143, LCM: 1.140 }, 
  '1000Y Free': { SCM: 1.144, LCM: 1.141 }, 
  '1650Y Free': { SCM: 1.011, LCM: 1.006 }, 
  '100Y Back': { SCM: 0.892, LCM: 0.865 },
  '200Y Back': { SCM: 0.892, LCM: 0.863 },
  '100Y Breast': { SCM: 0.893, LCM: 0.868 },
  '200Y Breast': { SCM: 0.892, LCM: 0.862 },
  '100Y Fly': { SCM: 0.896, LCM: 0.874 },
  '200Y Fly': { SCM: 0.895, LCM: 0.868 },
  '200Y IM': { SCM: 0.895, LCM: 0.867 },
  '400Y IM': { SCM: 0.894, LCM: 0.865 }
};

const POINTS_SCALE = [20, 17, 16, 15, 14, 13, 12, 11, 9, 7, 6, 5, 4, 3, 2, 1];

const TEAM_COLORS: Record<string, string> = {
  'Henderson State University': '#FF2A5F', 
  'Delta State University': '#00E676',     
  'Ouachita Baptist University': '#AA00FF' 
};

function App() {
  const [data, setData] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const [recruitFName, setRecruitFName] = useState('');
  const [recruitLName, setRecruitLName] = useState('');
  const [recruitTeam, setRecruitTeam] = useState('Ouachita Baptist University');
  const [recruitEvent, setRecruitEvent] = useState('50Y Free');
  const [recruitCourse, setRecruitCourse] = useState('SCY');
  const [recruitTime, setRecruitTime] = useState('');
  
  const [virtualRecruits, setVirtualRecruits] = useState<any[]>([]);
  const [expandedTeams, setExpandedTeams] = useState<Record<string, boolean>>({});

// Fix the White Border Issue globally
  useEffect(() => {
    document.body.style.margin = '0';
    document.body.style.padding = '0';
    document.body.style.backgroundColor = '#0b0d11';
    document.body.style.color = '#e2e8f0';
    // Updated to Helvetica Neue with safe fallbacks
    document.body.style.fontFamily = '"Helvetica Neue", Helvetica, Arial, sans-serif';
  }, []);
  
  const toggleTeam = (teamName: string) => {
    setExpandedTeams(prev => ({ ...prev, [teamName]: !prev[teamName] }));
  };

  const fetchAthletes = () => {
    fetch('http://127.0.0.1:3000/graphql', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        query: `
          query {
            athletes { id firstName lastName team raceResults { eventName timeSeconds round ncaaStatus } }
          }
        `
      })
    })
      .then(res => res.json())
      .then(result => {
        if (result.errors) setError(result.errors[0].message);
        else if (result.data) setData(result.data);
        else setError("API Error: No data payload received.");
        setLoading(false);
      })
      .catch(err => {
        setError(err.message);
        setLoading(false);
      });
  };

  useEffect(() => { fetchAthletes(); }, []);

  // --- SIMULATE RECRUIT IMPACT ---
  const handleSimulate = (e: React.FormEvent) => {
    e.preventDefault();
    let rawSeconds = parseInputTime(recruitTime);

    if (isNaN(rawSeconds)) {
      alert("Format error. Require SS.ms or M:SS.ms");
      return;
    }

    let convertedSeconds = rawSeconds;
    if (recruitCourse !== 'SCY') {
      const factor = CONVERSION_FACTORS[recruitEvent]?.[recruitCourse as 'SCM' | 'LCM'] || 1;
      convertedSeconds = Math.round((rawSeconds * factor) * 100) / 100; 
    }

    const isDistance = recruitEvent === '1000Y Free' || recruitEvent === '1650Y Free';
    const simulatedRound = isDistance ? 'Finals' : 'A-Final';

    const raceEntry = {
      eventName: recruitEvent,
      timeSeconds: convertedSeconds,
      round: simulatedRound,
      ncaaStatus: 'Projected',
      originalTime: recruitCourse !== 'SCY' ? `${recruitTime} ${recruitCourse}` : null
    };

    // Check if we already have this recruit active
    const existingIndex = virtualRecruits.findIndex(r => 
      r.firstName.trim().toLowerCase() === recruitFName.trim().toLowerCase() && 
      r.lastName.trim().toLowerCase() === recruitLName.trim().toLowerCase() &&
      r.team === recruitTeam
    );

    if (existingIndex >= 0) {
      // Append race to existing recruit
      const updatedRecruits = [...virtualRecruits];
      updatedRecruits[existingIndex].raceResults.push(raceEntry);
      setVirtualRecruits(updatedRecruits);
    } else {
      // Create new recruit card
      const newRecruit = {
        id: `V-ASSET-${Date.now()}`,
        firstName: recruitFName || 'Unknown',
        lastName: recruitLName || 'Asset',
        team: recruitTeam,
        isVirtual: true,
        raceResults: [raceEntry]
      };
      setVirtualRecruits([...virtualRecruits, newRecruit]);
    }

    // Clear just the time/course so they can quickly punch in another event
    setRecruitTime('');
    setRecruitCourse('SCY');
    setRecruitFName('');
    setRecruitLName('');
  };

  // Click shortcut to auto-fill the form with a recruit's details
  const loadRecruitToForm = (recruit: any) => {
    setRecruitFName(recruit.firstName);
    setRecruitLName(recruit.lastName);
    setRecruitTeam(recruit.team);
  };

  const removeRecruit = (id: string) => {
    setVirtualRecruits(virtualRecruits.filter(r => r.id !== id));
  };

  // --- THE MEET SCORING ENGINE ---
  const scoredTeams = useMemo(() => {
    const allAthletes = [...(data?.athletes || []), ...virtualRecruits];
    if (allAthletes.length === 0) return [];

    const athleteScores: Record<string, number> = {};
    const athleteRaces: Record<string, any[]> = {};
    
    allAthletes.forEach((a: any) => {
      athleteScores[a.id] = 0;
      athleteRaces[a.id] = [];
    });

    const events: Record<string, any[]> = {};
    
    allAthletes.forEach((a: any) => {
      a.raceResults?.forEach((r: any) => {
        const raceObj = { ...r, athleteId: a.id, pointsScored: 0, place: null };
        athleteRaces[a.id].push(raceObj);

        if (r.round === 'A-Final' || r.round === 'B-Final' || r.round === 'Finals') {
          if (!events[r.eventName]) events[r.eventName] = [];
          events[r.eventName].push(raceObj);
        }
      });
    });

    const assignPoints = (sortedRaces: any[], startingRank: number) => {
      let i = 0;
      while (i < sortedRaces.length) {
        let tieCount = 1;
        while (i + tieCount < sortedRaces.length && sortedRaces[i].timeSeconds === sortedRaces[i + tieCount].timeSeconds) {
          tieCount++;
        }
        
        let totalPoints = 0;
        for (let j = 0; j < tieCount; j++) {
          const placeIndex = startingRank + i + j;
          totalPoints += POINTS_SCALE[placeIndex] || 0;
        }
        
        const avgPoints = totalPoints / tieCount;
        const displayPlace = tieCount > 1 ? `T${startingRank + i + 1}` : `${startingRank + i + 1}`;

        for (let j = 0; j < tieCount; j++) {
          athleteScores[sortedRaces[i+j].athleteId] += avgPoints;
          sortedRaces[i+j].pointsScored = avgPoints;
          sortedRaces[i+j].place = displayPlace;
        }
        i += tieCount;
      }
    };

    Object.keys(events).forEach(eventName => {
      const races = events[eventName];
      if (eventName === '1650Y Free' || eventName === '1000Y Free') {
         assignPoints(races.sort((a, b) => a.timeSeconds - b.timeSeconds), 0);
      } else {
         const aFinals = races.filter(r => r.round === 'A-Final').sort((a, b) => a.timeSeconds - b.timeSeconds);
         const bFinals = races.filter(r => r.round === 'B-Final').sort((a, b) => a.timeSeconds - b.timeSeconds);
         assignPoints(aFinals, 0); 
         assignPoints(bFinals, aFinals.length); 
      }
    });

    const teamsMap: Record<string, any> = {};
    allAthletes.forEach((a: any) => {
      const teamName = a.team;
      if (!teamsMap[teamName]) {
        teamsMap[teamName] = { name: teamName, color: TEAM_COLORS[teamName] || '#fff', athletes: [], totalScore: 0 };
      }
      teamsMap[teamName].athletes.push({ ...a, score: athleteScores[a.id], scoredRaces: athleteRaces[a.id] });
      teamsMap[teamName].totalScore += athleteScores[a.id];
    });

    return Object.values(teamsMap)
      .sort((a, b) => b.totalScore - a.totalScore)
      .map(team => {
        team.athletes.sort((a: any, b: any) => b.score - a.score);
        return team;
      });

  }, [data, virtualRecruits]);

  const virtualStatsMap = useMemo(() => {
    const map: Record<string, any> = {};
    scoredTeams.forEach(team => {
      team.athletes.forEach((a: any) => {
        if (a.isVirtual) map[a.id] = a;
      });
    });
    return map;
  }, [scoredTeams]);


  if (loading) return <div style={styles.centerBox}>INITIALIZING DATALINK...</div>;
  if (error) return <div style={styles.centerBox}>SYSTEM ERROR: {error}</div>;

  return (
    <div style={styles.page}>
      <header style={styles.header}>
        <div style={styles.headerContent}>
          <div style={styles.logoIndicator}></div>
          <h1 style={styles.title}>NSISC // MEET OPS & RECRUIT MATRIX</h1>
        </div>
      </header>

      <div style={styles.container}>
        
        {/* ACTIVE PROJECTIONS PANEL */}
        {virtualRecruits.length > 0 && (
          <div style={styles.projectionsPanel}>
            <div style={styles.panelHeader}>
              <h3 style={styles.panelTitle}>ACTIVE RECRUIT PROJECTIONS</h3>
              <button onClick={() => setVirtualRecruits([])} style={styles.clearButton}>PURGE ALL</button>
            </div>
            <div style={styles.projectionsGrid}>
              {virtualRecruits.map(r => {
                const computedStats = virtualStatsMap[r.id];
                const races = computedStats?.scoredRaces || r.raceResults;

                return (
                  <div 
                    key={r.id} 
                    style={{ ...styles.projectionCard, borderLeft: `4px solid ${TEAM_COLORS[r.team]}` }}
                    onClick={() => loadRecruitToForm(r)}
                    title="Click to auto-fill form and add another event"
                  >
                    <div style={styles.projCardHeader}>
                      <div style={styles.projName}>{r.firstName} {r.lastName}</div>
                      <button onClick={(e) => { e.stopPropagation(); removeRecruit(r.id); }} style={styles.removeButton}>×</button>
                    </div>
                    
                    <div style={styles.projRacesContainer}>
                      {races.map((raceData: any, idx: number) => (
                        <div key={idx} style={styles.projRaceRow}>
                          <div style={{ flex: 1 }}>
                            <div style={styles.projEvent}>
                              {raceData.eventName}
                              {raceData.place && <span style={styles.projPlaceText}> • PL: {raceData.place}</span>}
                              {raceData.pointsScored !== undefined && <span style={styles.projPointsText}> • +{raceData.pointsScored} pts</span>}
                            </div>
                            {raceData.originalTime && <div style={styles.projConverted}>Orig: {raceData.originalTime}</div>}
                          </div>
                          <div style={{ textAlign: 'right', paddingLeft: '10px' }}>
                            <div style={styles.projTime}>
                              {formatDisplayTime(raceData.timeSeconds)} 
                              <span style={{fontSize:'0.7rem', color:'#64748b', marginLeft:'4px'}}>SCY</span>
                            </div>
                          </div>
                        </div>
                      ))}
                    </div>
                  </div>
                );
              })}
            </div>
          </div>
        )}

        {/* INPUT FORM CARD */}
        <div style={styles.card}>
          <h2 style={styles.cardTitle}>RECRUIT PROJECTION INPUT</h2>
          <form onSubmit={handleSimulate} style={styles.form}>
            <input style={styles.input} type="text" placeholder="First Name" value={recruitFName} onChange={e => setRecruitFName(e.target.value)} required />
            <input style={styles.input} type="text" placeholder="Last Name" value={recruitLName} onChange={e => setRecruitLName(e.target.value)} required />
            
            <select style={{ ...styles.input, flex: '2 1 200px' }} value={recruitTeam} onChange={e => setRecruitTeam(e.target.value)}>
              <option value="Henderson State University">Target: Henderson State</option>
              <option value="Ouachita Baptist University">Target: Ouachita Baptist</option>
              <option value="Delta State University">Target: Delta State</option>
            </select>

            <select style={styles.input} value={recruitEvent} onChange={e => setRecruitEvent(e.target.value)}>
              <option value="50Y Free">50 Free</option>
              <option value="100Y Free">100 Free</option>
              <option value="200Y Free">200 Free</option>
              <option value="500Y Free">500/400 Free</option>
              <option value="1000Y Free">1000/800 Free</option>
              <option value="1650Y Free">1650/1500 Free</option>
              <option value="100Y Back">100 Back</option>
              <option value="200Y Back">200 Back</option>
              <option value="100Y Breast">100 Breast</option>
              <option value="200Y Breast">200 Breast</option>
              <option value="100Y Fly">100 Fly</option>
              <option value="200Y Fly">200 Fly</option>
              <option value="200Y IM">200 IM</option>
              <option value="400Y IM">400 IM</option>
            </select>

            <select style={{...styles.input, flex: '0 1 80px', color: '#00E5FF', borderColor: '#00E5FF'}} value={recruitCourse} onChange={e => setRecruitCourse(e.target.value)}>
              <option value="SCY">SCY</option>
              <option value="SCM">SCM</option>
              <option value="LCM">LCM</option>
            </select>

            <input style={{...styles.input, fontFamily: 'monospace', letterSpacing: '1px'}} type="text" placeholder="Time (e.g. 20.45)" value={recruitTime} onChange={e => setRecruitTime(e.target.value)} required />
            <button type="submit" style={styles.button}>EXECUTE SIMULATION</button>
          </form>
        </div>

        {/* LIVE TEAM STANDINGS */}
        <h2 style={styles.sectionHeader}>TEAM/INDIVIDUAL SCORING STANDINGS</h2>
        
        {scoredTeams.map(team => {
          const top3 = team.athletes.slice(0, 3);
          const isExpanded = expandedTeams[team.name];

          return (
            <div key={team.name} style={styles.teamCard}>
              <div style={{...styles.teamHeaderBorder, backgroundColor: team.color}}></div>
              
              <div style={styles.teamHeader} onClick={() => toggleTeam(team.name)}>
                <div style={styles.teamScoreSection}>
                  <h2 style={styles.teamTitle}>{team.name}</h2>
                  <span style={styles.teamTotalPoints}>{team.totalScore.toFixed(1)} <span style={{fontSize: '0.9rem', color: '#64748b'}}>PTS</span></span>
                </div>
                
                <div style={styles.topScorersContainer}>
                  <p style={styles.topScorersLabel}>SWIMMERS:</p>
                  {top3.map((athlete: any) => (
                    <span key={athlete.id} style={{ ...styles.topScorerPill, borderColor: athlete.isVirtual ? '#00E5FF' : '#2B303B', color: athlete.isVirtual ? '#00E5FF' : '#94a3b8' }}>
                      {athlete.isVirtual && '◆ '} {athlete.firstName} {athlete.lastName} <strong style={{color: '#fff'}}>({athlete.score} PTS)</strong>
                    </span>
                  ))}
                  <span style={styles.expandIcon}>{isExpanded ? '▲' : '▼'}</span>
                </div>
              </div>

              {isExpanded && (
                <div style={styles.expandedRoster}>
                  {team.athletes.map((athlete: any) => (
                    <div key={athlete.id} style={{ ...styles.athleteRow, backgroundColor: athlete.isVirtual ? 'rgba(0, 229, 255, 0.05)' : 'transparent' }}>
                      <div style={styles.athleteInfo}>
                        <h3 style={styles.athleteNameExpanded}>
                          {athlete.firstName} {athlete.lastName} 
                          {athlete.isVirtual && <span style={styles.virtualBadge}>SIMULATED ASSET</span>}
                        </h3>
                        <span style={styles.athleteTotalPoints}>{athlete.score} PTS</span>
                      </div>
                      
                      <div style={{ ...styles.stackedRaceCard, borderColor: athlete.isVirtual ? '#00E5FF' : '#2B303B' }}>
                        {athlete.scoredRaces?.map((race: any, i: number) => {
                          let badgeStyle = styles.badgeNone;
                          if (race.ncaaStatus === 'A-Cut') badgeStyle = styles.badgeA;
                          if (race.ncaaStatus === 'B-Cut') badgeStyle = styles.badgeB;
                          if (race.ncaaStatus === 'Projected') badgeStyle = styles.badgeProjected;

                          const isLast = i === athlete.scoredRaces.length - 1;

                          return (
                            <div key={i} style={{ ...styles.stackedRaceRow, borderBottom: isLast ? 'none' : '1px solid #1e293b' }}>
                              <span style={{color: '#cbd5e1'}}><strong>{race.eventName}</strong> <span style={{color: '#64748b'}}>// {race.round}</span></span>
                              
                              <div style={{ display: 'flex', gap: '12px', alignItems: 'center' }}>
                                <span style={styles.rowPlaceText}>{race.place ? `PL: ${race.place}` : ''}</span>
                                <span style={styles.rowTimeText}>{formatDisplayTime(race.timeSeconds)}</span>
                                <span style={styles.rowPointsText}>{race.pointsScored > 0 ? `+${race.pointsScored}` : ''}</span>
                                <span style={{ ...styles.badge, ...badgeStyle, width: '65px', textAlign: 'center' }}>{race.ncaaStatus}</span>
                              </div>
                            </div>
                          );
                        })}
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>
          );
        })}
      </div>
    </div>
  );
}

// --- SHIELD.AI INSPIRED DARK THEME STYLES ---
const styles: { [key: string]: React.CSSProperties } = {
  page: { width: '100%', minHeight: '100vh' }, 
  
  header: { backgroundColor: '#111318', padding: '1.5rem', borderBottom: '1px solid #1e293b', boxShadow: '0 4px 20px rgba(0,0,0,0.5)' },
  headerContent: { maxWidth: '1000px', margin: '0 auto', display: 'flex', alignItems: 'center', gap: '15px' },
  logoIndicator: { width: '12px', height: '12px', backgroundColor: '#00E5FF', borderRadius: '50%', boxShadow: '0 0 12px #00E5FF' },
  title: { margin: 0, fontSize: '1.4rem', letterSpacing: '2px', color: '#f8fafc', fontWeight: '600' },
  
  container: { maxWidth: '1000px', margin: '0 auto', padding: '2rem' },
  centerBox: { display: 'flex', justifyContent: 'center', alignItems: 'center', height: '100vh', fontSize: '1.2rem', color: '#00E5FF', letterSpacing: '2px', fontFamily: 'monospace' },
  
  projectionsPanel: { backgroundColor: 'rgba(0, 229, 255, 0.03)', border: '1px solid rgba(0, 229, 255, 0.3)', borderRadius: '4px', padding: '1.5rem', marginBottom: '2.5rem' },
  panelHeader: { display: 'flex', justifyContent: 'space-between', alignItems: 'center', borderBottom: '1px solid rgba(0, 229, 255, 0.1)', paddingBottom: '10px', marginBottom: '15px' },
  panelTitle: { margin: 0, fontSize: '1rem', color: '#00E5FF', letterSpacing: '2px', fontWeight: 'bold' },
  clearButton: { backgroundColor: 'transparent', color: '#FF2A5F', border: '1px solid #FF2A5F', padding: '4px 12px', borderRadius: '2px', cursor: 'pointer', fontSize: '0.8rem', letterSpacing: '1px', transition: '0.2s' },
  
  projectionsGrid: { display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(280px, 1fr))', gap: '15px' },
  projectionCard: { display: 'flex', flexDirection: 'column', backgroundColor: '#161920', padding: '15px', borderRadius: '4px', border: '1px solid #2B303B', cursor: 'pointer', height: 'auto' },
  projCardHeader: { display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', borderBottom: '1px solid #2B303B', paddingBottom: '8px', marginBottom: '10px' },
  projName: { fontWeight: 'bold', color: '#f8fafc', fontSize: '1.1rem', letterSpacing: '0.5px' },
  removeButton: { background: 'none', border: 'none', color: '#64748b', fontSize: '1.5rem', cursor: 'pointer', padding: '0 0 0 10px', lineHeight: '1rem' },
  
  projRacesContainer: { display: 'flex', flexDirection: 'column', gap: '8px' },
  projRaceRow: { display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' },
  projEvent: { color: '#8A94A6', fontSize: '0.85rem' },
  projPlaceText: { color: '#00E5FF', fontWeight: 'bold' },
  projPointsText: { color: '#00E676', fontWeight: 'bold' },
  projTime: { fontFamily: 'monospace', color: '#00E5FF', fontSize: '1.1rem', fontWeight: 'bold', lineHeight: '1.2' },
  projConverted: { fontSize: '0.75rem', color: '#FF2A5F', marginTop: '2px' },

  card: { backgroundColor: '#161920', borderRadius: '4px', padding: '1.5rem', marginBottom: '3rem', border: '1px solid #2B303B', boxShadow: '0 10px 30px rgba(0,0,0,0.5)' },
  cardTitle: { margin: '0 0 1.5rem 0', fontSize: '1.1rem', color: '#8A94A6', letterSpacing: '2px', borderBottom: '1px solid #2B303B', paddingBottom: '0.8rem' },
  form: { display: 'flex', gap: '12px', flexWrap: 'wrap' },
  input: { padding: '12px', borderRadius: '2px', border: '1px solid #334155', backgroundColor: '#0f1115', color: '#f8fafc', fontSize: '0.95rem', flex: '1 1 120px', outline: 'none' },
  button: { padding: '12px 20px', borderRadius: '2px', border: 'none', backgroundColor: '#e2e8f0', color: '#0b0d11', fontSize: '0.95rem', cursor: 'pointer', fontWeight: 'bold', letterSpacing: '1px', flex: '1 1 150px' },
  
  sectionHeader: { color: '#8A94A6', borderBottom: '1px solid #2B303B', paddingBottom: '10px', fontSize: '1.1rem', letterSpacing: '2px', marginTop: '1rem' },

  teamCard: { backgroundColor: '#161920', borderRadius: '4px', marginBottom: '1.5rem', border: '1px solid #2B303B', position: 'relative' },
  teamHeaderBorder: { position: 'absolute', left: 0, top: 0, bottom: 0, width: '4px', borderTopLeftRadius: '4px', borderBottomLeftRadius: '4px' },
  teamHeader: { padding: '1.5rem 1.5rem 1.5rem 2rem', display: 'flex', flexDirection: 'column', gap: '12px', cursor: 'pointer', userSelect: 'none' },
  teamScoreSection: { display: 'flex', justifyContent: 'space-between', alignItems: 'center' },
  teamTitle: { margin: 0, fontSize: '1.5rem', fontWeight: '600', color: '#f8fafc', letterSpacing: '1px' },
  teamTotalPoints: { fontSize: '1.6rem', fontWeight: 'bold', color: '#00E5FF', fontFamily: 'monospace' },
  
  topScorersContainer: { display: 'flex', alignItems: 'center', flexWrap: 'wrap', gap: '10px' },
  topScorersLabel: { margin: 0, fontSize: '0.8rem', color: '#64748b', fontWeight: 'bold', letterSpacing: '1px' },
  topScorerPill: { backgroundColor: '#0f1115', padding: '4px 12px', borderRadius: '2px', fontSize: '0.85rem', border: '1px solid #2B303B' },
  expandIcon: { marginLeft: 'auto', color: '#64748b', fontSize: '1rem' },

  expandedRoster: { padding: '0 1.5rem 1.5rem 2rem', borderTop: '1px solid #2B303B', backgroundColor: '#0b0d11' },
  athleteRow: { padding: '1.5rem 1rem', borderBottom: '1px solid #1e293b' },
  athleteInfo: { display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '15px' },
  athleteNameExpanded: { margin: 0, fontSize: '1.2rem', color: '#f8fafc', display: 'flex', alignItems: 'center', gap: '12px', letterSpacing: '0.5px' },
  virtualBadge: { fontSize: '0.7rem', backgroundColor: 'transparent', color: '#00E5FF', border: '1px solid #00E5FF', padding: '3px 8px', borderRadius: '2px', letterSpacing: '1px' },
  athleteTotalPoints: { fontWeight: 'bold', color: '#8A94A6', fontSize: '1rem', fontFamily: 'monospace' },
  
  stackedRaceCard: { display: 'flex', flexDirection: 'column', backgroundColor: '#161920', borderRadius: '4px', borderLeft: '2px solid #334155', padding: '0 15px' },
  stackedRaceRow: { display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '10px 0' },
  
  rowPlaceText: { color: '#8A94A6', fontSize: '0.9rem', width: '45px', textAlign: 'right', fontWeight: 'bold' },
  rowTimeText: { fontFamily: 'monospace', fontSize: '1.05rem', color: '#f8fafc', width: '80px', textAlign: 'right' },
  rowPointsText: { color: '#00E676', fontSize: '0.9rem', width: '45px', textAlign: 'right', fontWeight: 'bold' },
  
  badge: { padding: '4px 0', borderRadius: '2px', fontSize: '0.7rem', fontWeight: 'bold', letterSpacing: '1px' },
  badgeA: { backgroundColor: 'rgba(0, 230, 118, 0.1)', color: '#00E676', border: '1px solid #00E676' },
  badgeB: { backgroundColor: 'rgba(255, 170, 0, 0.1)', color: '#FFAA00', border: '1px solid #FFAA00' },
  badgeProjected: { backgroundColor: 'rgba(0, 229, 255, 0.1)', color: '#00E5FF', border: '1px solid #00E5FF' },
  badgeNone: { backgroundColor: 'transparent', color: '#64748b', border: '1px solid #334155' }
};

export default App;